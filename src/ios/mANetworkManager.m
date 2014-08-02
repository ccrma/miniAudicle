//
//  mANetworkManager.m
//  miniAudicle
//
//  Created by Spencer Salazar on 4/13/14.
//
//

#import "mANetworkManager.h"
#import "mANetworkAction.h"


NSString * const MINIAUDICLE_HOST = @"localhost";
const int MINIAUDICLE_PORT = 8080;


@interface NSDictionary (HTTP)

- (NSData *)toHTTPBody;

@end

@interface NSString (URLEncode)

- (NSString *)urlEncode;

@end


@implementation mANetworkRoom

@end


@interface mANetworkManager ()
{
    NSInteger _lastAction;
}

@property (strong, nonatomic) NSString *roomId;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) void (^updateHandler)(mANetworkAction *);
@property (strong, nonatomic) void (^errorHandler)(NSError *);
@property (strong, nonatomic) NSMutableDictionary *activeUsers;
@property (nonatomic) BOOL requestActive;

- (void)update:(NSTimer *)timer;
- (void)startUpdating;
- (void)stopUpdating;

@end

@implementation mANetworkManager

+ (id)instance
{
    static mANetworkManager *s_manager = nil;
    if(s_manager == nil)
        s_manager = [mANetworkManager new];
    return s_manager;
}

- (id)init
{
    if(self = [super init])
    {
        self.serverHost = MINIAUDICLE_HOST;
        self.serverPort = MINIAUDICLE_PORT;
        self.requestActive = NO;
    }
    
    return self;
}

- (NSString *)userId
{
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

- (NSURL *)makeURL:(NSString *)path
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%li%@",
                                 self.serverHost, (long) self.serverPort, path]];
}

- (void)listRooms:(void (^)(NSArray *))listHandler // array of mANetworkRoom
     errorHandler:(void (^)(NSError *))errorHandler
{
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[self makeURL:@"/rooms"]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *_response, NSData *data, NSError *error) {
                               NSHTTPURLResponse *response = (NSHTTPURLResponse *) _response;
                               if(response.statusCode == 200)
                               {
                                   NSArray *rooms = [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:0
                                                                                      error:&error];
                                   if(rooms != nil)
                                       listHandler(rooms);
                                   else
                                       errorHandler(error);

                               }
                               else
                               {
                                   errorHandler(error);
                               }
                           }];
}

- (void)joinRoom:(NSString *)roomId
         handler:(void (^)(mANetworkAction *))updateHandler
    errorHandler:(void (^)(NSError *))errorHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[self makeURL:[NSString stringWithFormat:@"/rooms/%@/join", roomId]]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[@{ @"user_id": [self userId],
                             @"user_name": @"spencer"
                             } toHTTPBody]];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    __weak typeof(self) weakSelf = self;

    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *_response, NSData *data, NSError *error) {
                               
                               NSHTTPURLResponse *response = (NSHTTPURLResponse *) _response;
                               typeof(self) strongSelf = weakSelf;
                               
                               if(response.statusCode == 200)
                               {
                                   strongSelf.roomId = roomId;
                                   strongSelf.updateHandler = updateHandler;
                                   strongSelf.errorHandler = errorHandler;
                                   strongSelf->_lastAction = -1;
                                   strongSelf.activeUsers = [NSMutableDictionary new];
                                   [strongSelf startUpdating];
                               }
                               else
                               {
                                   errorHandler(error);
                               }
                           }];
}

- (void)leaveCurrentRoom
{
    [self stopUpdating];
}

- (void)update:(NSTimer *)timer
{
    if(self.requestActive) return;
    
    self.requestActive = YES;
    
    NSString *format;
    if(_lastAction >= 0) format = [NSString stringWithFormat:@"/rooms/%@/actions?after=%li", self.roomId, (long)_lastAction];
    else format = [NSString stringWithFormat:@"/rooms/%@/actions", self.roomId];
    
    __weak typeof(self) weakSelf = self;

    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:[self makeURL:format]]
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *_response, NSData *data, NSError *error) {
                               NSHTTPURLResponse *response = (NSHTTPURLResponse *) _response;
                               typeof(self) strongSelf = weakSelf;
                               
                               if(response.statusCode == 200)
                               {
                                   NSArray *actions = [NSJSONSerialization JSONObjectWithData:data
                                                                                      options:0
                                                                                        error:&error];
                                   
                                   if(actions != nil)
                                   {
                                       for(NSDictionary *actionDict in actions)
                                       {
                                           mANetworkAction *action = [mANetworkAction networkActionWithObject:actionDict];
                                           
                                           if([[action class] isSubclassOfClass:[mANAJoinRoom class]])
                                           {
                                               mANAJoinRoom *joinRoom = (mANAJoinRoom *) action;
                                               [self.activeUsers setObject:joinRoom.user_name forKey:joinRoom.user_id];
                                           }
                                           
                                           if(![action.user_id isEqualToString:[strongSelf userId]])
                                           {
                                               NSLog(@"got action: %@", actionDict);
                                               strongSelf.updateHandler(action);
                                           }
                                           
                                           strongSelf->_lastAction = action.aid;
                                       }
                                   }
                               }
                               else
                               {
                                   strongSelf.errorHandler(error);
                               }
                               
                               self.requestActive = NO;
                           }];
}

- (void)startUpdating
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                  target:self
                                                selector:@selector(update:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopUpdating
{
    [self.timer invalidate];
    self.timer = nil;
}

- (NSString *)usernameForUserID:(NSString *)userID
{
    if(self.activeUsers)
        return [self.activeUsers objectForKey:userID];
    else
        return nil;
}


@end



@implementation NSDictionary (HTTP)

- (NSData *)toHTTPBody
{
    NSMutableString *string = [NSMutableString string];
    BOOL first = YES;
    for(NSString *key in self)
    {
        if(!first) [string appendString:@"&"];
        else first = NO;
        
        [string appendFormat:@"%@=%@", [key urlEncode], [[self objectForKey:key] urlEncode]];
    }
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

@end

@implementation NSString (URLEncode)

- (NSString *)urlEncode
{
    return (NSString *) CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef) self, NULL, (CFStringRef) @"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

@end



