//
//  mANetworkManager.h
//  miniAudicle
//
//  Created by Spencer Salazar on 4/13/14.
//
//

#import <Foundation/Foundation.h>

@class mANetworkAction;

@interface mANetworkRoom : NSObject

@property (copy, nonatomic) NSString *uuid;
@property (copy, nonatomic) NSString *name;

@end

@interface mANetworkManager : NSObject

@property (copy, nonatomic) NSString *serverHost;
@property (nonatomic) NSInteger serverPort;

+ (id)instance;

- (NSString *)userId;
- (NSURL *)makeURL:(NSString *)path;
- (void)listRooms:(void (^)(NSArray *))listHandler // array of mANetworkRoom
     errorHandler:(void (^)(NSError *))errorHandler;
- (void)joinRoom:(NSString *)roomId
         handler:(void (^)(mANetworkAction *))updateHandler
    errorHandler:(void (^)(NSError *))errorHandler;
- (void)leaveCurrentRoom;

- (NSString *)usernameForUserID:(NSString *)userID;

@end
