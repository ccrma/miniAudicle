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

@property (nonatomic) NSInteger type;

+ (id)networkActionWithObject:(NSDictionary *)object;
- (id)initWithObject:(NSDictionary *)object;
- (void)execute:(mAPlayerViewController *)player;

@end


@interface mAAddShredNetworkAction : mANetworkAction

@property (copy, nonatomic) NSString *code;

+ (id)addShredNetworkActionWithCode:(NSString *)code;

@end

