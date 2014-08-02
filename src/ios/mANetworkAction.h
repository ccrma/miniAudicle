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

@property (nonatomic) NSInteger aid;
@property (copy, nonatomic) NSString *user_id;
@property (copy, nonatomic) NSString *type;

+ (id)networkActionWithObject:(NSDictionary *)object;
- (id)initWithObject:(NSDictionary *)object;
- (void)execute:(mAPlayerViewController *)player;

@end


@interface mANAJoinRoom : mANetworkAction
@property (copy, nonatomic) NSString *user_name;
- (void)execute:(mAPlayerViewController *)player;
@end


@interface mANALeaveRoom : mANetworkAction
- (void)execute:(mAPlayerViewController *)player;
@end


@interface mANANewScript : mANetworkAction
@property (copy, nonatomic) NSString *code_id;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *code;
- (void)execute:(mAPlayerViewController *)player;
@end


@interface mANADeleteScript : mANetworkAction
@property (copy, nonatomic) NSString *code_id;
- (void)execute:(mAPlayerViewController *)player;
@end


@interface mANAAddShred : mANetworkAction
@property (copy, nonatomic) NSString *code_id;
- (void)execute:(mAPlayerViewController *)player;
@end


@interface mANAReplaceShred : mANetworkAction
@property (copy, nonatomic) NSString *code_id;
- (void)execute:(mAPlayerViewController *)player;
@end


@interface mANARemoveShred : mANetworkAction
@property (copy, nonatomic) NSString *code_id;
- (void)execute:(mAPlayerViewController *)player;
@end

