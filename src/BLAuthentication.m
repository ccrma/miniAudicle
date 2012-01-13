//  ======================================================================      //
//  BLAuthentication.h                                                                                                          //
//                                                                                                                                              //
//  Last Modified on Tuesday April 24 2001                                                                      //
//  Copyright 2001 Ben Lachman                                                                                          //
//                                                                                                                                                      //
//      Thanks to Brian R. Hill <http://personalpages.tds.net/~brian_hill/>             //
//  ======================================================================      //

#import "BLAuthentication.h"
#import <Security/AuthorizationTags.h>

@implementation BLAuthentication

// returns an instace of itself, creating one if needed
+ sharedInstance {
    static id _sharedTask = nil;
    if(_sharedTask == nil) {
        _sharedTask = [[BLAuthentication alloc] init];
    }
    return _sharedTask;
}

// Returns the delegate
- (id)delegate {
	return _delegate;
}

// Sets the delegate
- (void)setDelegate:(id)delegate  {
	_delegate = delegate;
}


	// initializes the super class and sets _authorizationRef to NULL 
- (id)init {
    self = [super init];
    _authorizationRef = NULL;
	_delegate = nil;
    return self;
}

// deauthenticates the user and deallocates memory
- (void)dealloc {
    [self deauthenticate];
    [super dealloc];
}

//============================================================================
//      - (BOOL)isAuthenticated:(NSArray *)forCommands
//============================================================================
// Find outs if the user has the appropriate authorization rights for the 
// commands listed in (NSArray *)forCommands.
// This should be called each time you need to know whether the user
// is authorized, since the AuthorizationRef can be invalidated elsewhere, or
// may expire after a short period of time.
//
- (BOOL)isAuthenticated:(NSString *)forCommand {	
	AuthorizationItem items[1];
	AuthorizationRights rights;
	AuthorizationRights *authorizedRights;
	AuthorizationFlags flags;
	
	OSStatus err = 0;
	BOOL authorized = NO;
	int i = 0;
	
	if(_authorizationRef == NULL) {
		rights.count = 0;
		rights.items = NULL;
		
		flags = kAuthorizationFlagDefaults;
		err = AuthorizationCreate(&rights, kAuthorizationEmptyEnvironment, flags, &_authorizationRef);
	}
	
	char *command = malloc(sizeof(char) * 1024);
	[forCommand getCString:command maxLength:1024];
	items[0].name = kAuthorizationRightExecute;
	items[0].value = command;
	items[0].valueLength = strlen(command);
	items[0].flags = 0;
	
    rights.count = 1;
    rights.items = items;
    
    flags = kAuthorizationFlagExtendRights;
    
    err = AuthorizationCopyRights(_authorizationRef, &rights, kAuthorizationEmptyEnvironment, flags, &authorizedRights);
	
    authorized = (errAuthorizationSuccess == err);
	
	if(authorized) {		
		AuthorizationFreeItemSet(authorizedRights);
	}
	
    return authorized;
}

//============================================================================
//      - (void)deauthenticate
//============================================================================
// Deauthenticates the user by freeing their authorization.
//
- (void)deauthenticate {
    if(_authorizationRef) {
        AuthorizationFree(_authorizationRef, kAuthorizationFlagDestroyRights);
        _authorizationRef = NULL;
		if (_delegate)
		{
			[_delegate authenticationDidDeauthorize:self];
		}
    }
}

//============================================================================
//      - (BOOL)fetchPassword:(NSArray *)forCommands
//============================================================================
// Adds rights for commands specified in (NSArray *)forCommands.
// Commands should be passed as a NSString comtaining the path to the executable. 
// Returns YES if rights were gained
//
- (BOOL)fetchPassword:(NSString *)forCommand {
	AuthorizationItem items[1];
	AuthorizationRights rights;
	AuthorizationRights *authorizedRights;
	AuthorizationFlags flags;
	
	OSStatus err = 0;
	BOOL authorized = NO;
	int i = 0;
	
	if(_authorizationRef == NULL) {
		rights.count = 0;
		rights.items = NULL;
		
		flags = kAuthorizationFlagDefaults;
		err = AuthorizationCreate(&rights, kAuthorizationEmptyEnvironment, flags, &_authorizationRef);
	}
	
	char *command = malloc(sizeof(char) * 1024);
	[forCommand getCString:command maxLength:1024];
	items[0].name = kAuthorizationRightExecute;
	items[0].value = command;
	items[0].valueLength = strlen(command);
	items[0].flags = 0;
	
    rights.count = 1;
    rights.items = items;
    
	flags = kAuthorizationFlagInteractionAllowed | kAuthorizationFlagExtendRights;
	
	err = AuthorizationCopyRights(_authorizationRef, &rights, kAuthorizationEmptyEnvironment, flags, &authorizedRights);
	
	authorized = (errAuthorizationSuccess == err);
	
	if(authorized) {
		AuthorizationFreeItemSet(authorizedRights);
		if (_delegate)
		{
			[_delegate authenticationDidAuthorize:self];
		}
	}                                                    
	
	return authorized;
}

//============================================================================
//      - (BOOL)authenticate:(NSArray *)forCommands
//============================================================================
// Authenticates the commands in the array (NSArray *)forCommands by calling 
// fetchPassword.
//
- (BOOL)authenticate:(NSString *)forCommand {
	if( ![self isAuthenticated:forCommand] ) {
        [self fetchPassword:forCommand];
	}
	
	return [self isAuthenticated:forCommand];
}


//============================================================================
//      - (int)getPID:(NSString *)forProcess
//============================================================================
// Retrieves the PID (process ID) for the process specified in 
// (NSString *)forProcess.
// The more specific forProcess is the better your accuracy will be, esp. when 
// multiple versions of the process exist. 
//
- (int)getPID:(NSString *)forProcess {
	FILE* outpipe = NULL;
	NSMutableData* outputData = [NSMutableData data];
	NSMutableData* tempData = [[NSMutableData alloc] initWithLength:512];
	NSString *commandOutput = nil;
	NSString *scannerOutput = nil;
	NSString *popenArgs = [[NSString alloc] initWithFormat:@"/bin/ps -axwwopid,command | grep \"%@\"", forProcess];
	NSScanner *outputScanner = nil;
	NSScanner *intScanner = nil;
	int pid = 0;
	int len = 0;
    
    outpipe = popen([popenArgs cString],"r");
	
	[popenArgs release];
	
	if(!outpipe) {
        NSLog(@"Error opening pipe: %@",forProcess);
        NSBeep();
        return nil;
    }
	
	do {
        [tempData setLength:512];
        len = fread([tempData mutableBytes],1,512,outpipe);
        if( len > 0 ) {
            [tempData setLength:len];
            [outputData appendData:tempData];        
		}
	} while(len==512);
    
	[tempData release];
	
	pclose(outpipe);
	
	commandOutput = [[NSString alloc] initWithData:outputData encoding:NSASCIIStringEncoding];    
	
	if( [commandOutput length] > 0 ) {
		outputScanner = [NSScanner scannerWithString:commandOutput];
		
		[commandOutput release];
		
		[outputScanner setCharactersToBeSkipped:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		[outputScanner scanUpToString:forProcess intoString:&scannerOutput];
		
		if( [scannerOutput rangeOfString:@"grep"].length != 0 ) {
			return 0;
		}
		
		intScanner = [NSScanner scannerWithString:scannerOutput];
		
		[intScanner scanInt:&pid];
		
		if( pid ) {
			return pid;
		}
		else {
			return 0;
		}
	}
	else {
		[commandOutput release];
		
		return 0;
	}
}


//============================================================================
//      -(void)executeCommand:(NSString *)pathToCommand withArgs:(NSArray *)arguments
//============================================================================
// Executes command in (NSString *)pathToCommand with the arguments listed in
// (NSArray *)arguments as root.
// pathToCommand should be a string contain the path to the command 
// (eg., /usr/bin/more), arguments should be an array of strings each containing
// a single argument.
//
-(BOOL)executeCommand:(NSString *)pathToCommand withArgs:(NSArray *)arguments {
	char* args[30]; // can only handle 30 arguments to a given command
	OSStatus err = 0;
	unsigned int i = 0;
	
	if(![self authenticate:pathToCommand])
		return NO;
	
	if( arguments == nil || [arguments count] < 1  ) {
		err = AuthorizationExecuteWithPrivileges(_authorizationRef, [pathToCommand fileSystemRepresentation], 0, NULL, NULL);
	}
	else {
		while( i < [arguments count] && i < 19) {
			args[i] = (char*)[[arguments objectAtIndex:i] cString];
			i++;
		}
		args[i] = NULL;
		
		err = AuthorizationExecuteWithPrivileges(_authorizationRef, [pathToCommand fileSystemRepresentation],
												 0, args, NULL);
	}
	
	if(err != 0) {
		NSLog(@"Error %d in AuthorizationExecuteWithPrivileges",err);
		if (_delegate)
		{
			[_delegate authenticationFailedExecute:self];
		}
		return NO;
	}
	else {
		if (_delegate)
		{
			[_delegate authenticationDidExecute:self];
		}
		return YES;
	}
}

-(BOOL)executeCommandSynced:(NSString *)pathToCommand withArgs:(NSArray *)arguments {
	char* args[30]; // can only handle 30 arguments to a given command
	OSStatus err = 0;
	unsigned int i = 0;
	FILE* f;
	char buffer[1024];
	unsigned long ticks;
	
	if(![self authenticate:pathToCommand])
	{
		return NO;
	}
	
	if( arguments == nil || [arguments count] < 1  ) {
		err = AuthorizationExecuteWithPrivileges(_authorizationRef, [pathToCommand fileSystemRepresentation], 0, NULL, &f);
	}
	else {
		while( i < [arguments count] && i < 19) {
			args[i] = (char*)[[arguments objectAtIndex:i] cString];
			i++;
		}
		args[i] = NULL;
		
		const char* dbg = [pathToCommand fileSystemRepresentation];
		err = AuthorizationExecuteWithPrivileges(_authorizationRef,
												 [pathToCommand fileSystemRepresentation],
												 kAuthorizationFlagDefaults,
												 args,
												 &f);
	}
	
	if(err!=0) {
		NSLog(@"Error %d in AuthorizationExecuteWithPrivileges",err);
		if (_delegate)
		{
			[_delegate authenticationFailedExecute:self];
		}
		return NO;
	}
	else {
		int bytesRead;
		if (f) {
			NSLog(@"Reading pipe");
            for (;;) {
                bytesRead = fread(buffer, 1, 1024, f);
                if (bytesRead < 1) break;
				NSLog([NSString stringWithCString:buffer length:bytesRead]);
            }
			fflush(f);
			fclose(f);
		}
		if (_delegate)
		{
			[_delegate authenticationDidExecute:self];
		}
		return YES;
	}
}

//============================================================================
//      - (void)killProcess:(NSString *)commandFromPS
//============================================================================
// Finds and kills the process specified in (NSString *)commandFromPS using ps 
// and kill. (by pid)
// The more specific (ie., closer to matching the actual listing in ps) 
// commandFromPS is the better your accuracy will be, esp. when multiple 
// versions of the process exist.
//
- (BOOL)killProcess:(NSString *)commandFromPS withSignal:(int)signal {
	NSString *pid;
	NSString *sig = [NSString stringWithFormat:@"%d", signal];
	
	if( ![self isAuthenticated:commandFromPS] ) {
		[self authenticate:commandFromPS];
	}
	
	pid = [NSString stringWithFormat:@"%d",[self getPID:commandFromPS]];
	
	if( [pid intValue] > 0 ) {
		[self executeCommand:@"/bin/kill" withArgs:[NSArray arrayWithObjects:pid, sig, nil]];
		if (_delegate)
		{
			[_delegate authenticationDidKill:self];
		}
		return YES;
	}
	else {
		NSLog(@"Error killing process %@, invalid PID.",pid);
		if (_delegate)
		{
			[_delegate authenticationFailedKill:self];
		}
		return NO;
	}
}       
@end
