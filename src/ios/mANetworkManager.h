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
@property (copy, nonatomic) NSString *info;

@end

@interface mANetworkRoomMember : NSObject

@property (copy, nonatomic) NSString *uuid;
@property (copy, nonatomic) NSString *name;

@end

@interface mANetworkManager : NSObject

@property (copy, nonatomic) NSString *serverHost;
@property (nonatomic) NSInteger serverPort;
@property (nonatomic, readonly) BOOL isConnected;

+ (id)instance;

- (NSString *)userId;
- (NSURL *)makeURL:(NSString *)path;
- (void)listRooms:(void (^)(NSArray *))listHandler // array of mANetworkRoom
     errorHandler:(void (^)(NSError *))errorHandler;
- (void)joinRoom:(NSString *)roomId
        username:(NSString *)username
  successHandler:(void (^)())successHandler
   updateHandler:(void (^)(mANetworkAction *))updateHandler
    errorHandler:(void (^)(NSError *))errorHandler;
- (void)leaveCurrentRoom;

- (void)submitAction:(mANetworkAction *)action
        errorHandler:(void (^)(NSError *))errorHandler;

- (NSString *)usernameForUserID:(NSString *)userID;

@end
