//
//  mANetworkRoomView.h
//  miniAudicle
//
//  Created by Spencer Salazar on 8/7/14.
//
//

#import <UIKit/UIKit.h>

@class mANetworkRoom;
@class mANetworkRoomMember;

@interface mANetworkRoomView : UIView

@property (copy, nonatomic) mANetworkRoom *room;

- (void)addMember:(mANetworkRoomMember *)member;
- (void)removeMember:(mANetworkRoomMember *)member;

@end
