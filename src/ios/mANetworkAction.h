//
//  mANetworkAction.h
//  miniAudicle
//
//  Created by Spencer Salazar on 4/13/14.
//
//

#import <Foundation/Foundation.h>


@class mAPlayerViewController;


@interface mANetworkAction : NSObject

@property (nonatomic) NSInteger _id;
@property (copy, nonatomic) NSString *user_id;
@property (copy, nonatomic) NSString *type;

+ (id)networkActionWithObject:(NSDictionary *)object;
- (id)initWithObject:(NSDictionary *)object;
- (void)execute:(mAPlayerViewController *)player;

@end


@interface mANAJoinRoom : mANetworkAction
@property (copy, nonatomic) NSString *name;
@end

@interface mANALeaveRoom : mANetworkAction
@end

@interface mANANewScript : mANetworkAction
@property (copy, nonatomic) NSString *code_id;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *code;
@end

@interface mANADeleteScript : mANetworkAction
@property (copy, nonatomic) NSString *code_id;
@end

@interface mANAAddShred : mANetworkAction
@property (copy, nonatomic) NSString *code_id;
@end

@interface mANAReplaceShred : mANetworkAction
@property (copy, nonatomic) NSString *code_id;
@end

@interface mANARemoveShred : mANetworkAction
@property (copy, nonatomic) NSString *code_id;
@end

