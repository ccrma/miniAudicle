//  ======================================================================      //
//  BLAuthentication.h                                                                                                          //
//                                                                                                                                              //
//  Last Modified on Tuesday April 24 2001                                                                      //
//  Copyright 2001 Ben Lachman                                                                                          //
//                                                                                                                                                      //
//      Thanks to Brian R. Hill <http://personalpages.tds.net/~brian_hill/>             //
//  ======================================================================      //

#import <Cocoa/Cocoa.h>
#import <Security/Authorization.h>

@interface BLAuthentication : NSObject 
{
	AuthorizationRef _authorizationRef;
	id _delegate;
}

// returns a shared instance of the class
+ sharedInstance;

- (id)delegate;
- (void)setDelegate:(id)delegate;

- (BOOL)isAuthenticated:(NSString *)forCommand;
- (BOOL)authenticate:(NSString *)forCommand;
- (void)deauthenticate;

- (int)getPID:(NSString *)forProcess;

- (BOOL)executeCommand:(NSString *)pathToCommand withArgs:(NSArray *)arguments;
- (BOOL)executeCommandSynced:(NSString *)pathToCommand withArgs:(NSArray *)arguments;
- (BOOL)killProcess:(NSString *)commandFromPS withSignal:(int)signal;

@end


/*!
 @category NSObject(BLAuthenticationDelegate)
 @abstract Optionally implement these delegate methods to obtain the state of the authorization object.
 */
@interface NSObject (BLAuthenticationDelegate)

- (void)authenticationDidAuthorize:(BLAuthentication *)authentication;
- (void)authenticationDidDeauthorize:(BLAuthentication *)authentication;

- (void)authenticationDidExecute:(BLAuthentication *)authentication;
- (void)authenticationFailedExecute:(BLAuthentication *)authentication;

- (void)authenticationDidKill:(BLAuthentication *)authentication;
- (void)authenticationFailedKill:(BLAuthentication *)authentication;

@end
