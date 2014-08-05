//
//  mANetworkAction.m
//  miniAudicle
//
//  Created by Spencer Salazar on 4/13/14.
//
//

#import "mANetworkAction.h"
#import "mAPlayerViewController.h"
#import "mAScriptPlayer.h"
#import "mADetailItem.h"
#import "NSObject+KVCSerialization.h"


static NSString * const mANAJoinRoomType = @"join";
static NSString * const mANALeaveRoomType = @"leave";
static NSString * const mANANewScriptType = @"new";
static NSString * const mANADeleteScriptType = @"delete";
static NSString * const mANAAddShredType = @"add";
static NSString * const mANAReplaceShredType = @"replace";
static NSString * const mANARemoveShredType = @"remove";

static NSDictionary *mANAClassTypes = nil;

@implementation mANetworkAction

+ (void)initialize
{
    if(self == [mANetworkAction self])
    {
        mANAClassTypes = @{
                           mANAJoinRoomType: [mANAJoinRoom class],
                           mANALeaveRoomType: [mANALeaveRoom class],
                           mANANewScriptType: [mANANewScript class],
                           mANADeleteScriptType: [mANADeleteScript class],
                           mANAAddShredType: [mANAAddShred class],
                           mANAReplaceShredType: [mANAReplaceShred class],
                           mANARemoveShredType: [mANARemoveShred class],
                           };
    }
}

+ (id)networkActionWithObject:(NSDictionary *)object
{
    NSString *type = [object objectForKey:@"type"];
    
    if([mANAClassTypes objectForKey:type])
        return [[[mANAClassTypes objectForKey:type] alloc] initWithObject:object];
    else
        NSLog(@"Warning: unknown network action type '%@'", type);
    
    return nil;
}

- (id)initWithObject:(NSDictionary *)object
{
    if(self = [super init])
    {
        for(NSString *key in object)
        {
            if([self keyExists:key])
                [self setValue:[object objectForKey:key] forKey:key];
        }
    }
    
    return self;
}

- (void)execute:(mAPlayerViewController *)player
{
    // no-op
}

@end


@implementation mANAJoinRoom

- (void)execute:(mAPlayerViewController *)player
{
    
}

@end

@implementation mANALeaveRoom

- (void)execute:(mAPlayerViewController *)player
{
    
}

@end

@implementation mANANewScript

- (void)execute:(mAPlayerViewController *)player
{
    mADetailItem *detailItem = [mADetailItem remoteDetailItemWithNewScriptAction:self];
    [player addScript:detailItem];
}

@end

@implementation mANADeleteScript

- (void)execute:(mAPlayerViewController *)player
{
    
}

@end

@implementation mANAAddShred

- (void)execute:(mAPlayerViewController *)player
{
    mAScriptPlayer *scriptPlayer = [player scriptPlayerForRemoteUUID:self.code_id];
    [scriptPlayer addShred:nil];
}

@end

@implementation mANAReplaceShred

- (void)execute:(mAPlayerViewController *)player
{
    mAScriptPlayer *scriptPlayer = [player scriptPlayerForRemoteUUID:self.code_id];
    [scriptPlayer replaceShred:nil];
}

@end

@implementation mANARemoveShred

- (void)execute:(mAPlayerViewController *)player
{
    mAScriptPlayer *scriptPlayer = [player scriptPlayerForRemoteUUID:self.code_id];
    [scriptPlayer removeShred:nil];
}

@end

