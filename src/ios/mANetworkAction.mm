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
#import "mANetworkManager.h"


static NSString * const mANAJoinRoomType = @"join";
static NSString * const mANALeaveRoomType = @"leave";
static NSString * const mANANewScriptType = @"new";
static NSString * const mANADeleteScriptType = @"delete";
static NSString * const mANAAddShredType = @"add";
static NSString * const mANAReplaceShredType = @"replace";
static NSString * const mANARemoveShredType = @"remove";

static NSDictionary *mANAClassTypes = nil;
static NSDictionary *mANATypeClasses = nil; // inverse of above

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
        return [[[mANAClassTypes objectForKey:type] alloc] initWithDictionary:object];
    else
        NSLog(@"Warning: unknown network action type '%@'", type);
    
    return nil;
}

- (id)init
{
    if(self = [super init])
    {
    }
    
    return self;
}

- (void)execute:(mAPlayerViewController *)player
{
    // no-op
}

@end


@implementation mANAJoinRoom

- (id)init
{
    if(self = [super init])
    {
        self.type = mANAJoinRoomType;
    }
    
    return self;
}

- (void)execute:(mAPlayerViewController *)player
{
    mANetworkRoomMember *member = [mANetworkRoomMember new];
    member.uuid = self.user_id;
    member.name = self.user_name;
    [player memberJoined:member];
}

@end

@implementation mANALeaveRoom

- (id)init
{
    if(self = [super init])
    {
        self.type = mANALeaveRoomType;
    }
    
    return self;
}

- (void)execute:(mAPlayerViewController *)player
{
    mANetworkRoomMember *member = [mANetworkRoomMember new];
    member.uuid = self.user_id;
    [player memberLeft:member];
}

@end

@implementation mANANewScript

- (id)init
{
    if(self = [super init])
    {
        self.type = mANANewScriptType;
    }
    
    return self;
}

- (void)execute:(mAPlayerViewController *)player
{
    mADetailItem *detailItem = [mADetailItem remoteDetailItemWithNewScriptAction:self];
    [player addScript:detailItem];
}

@end

@implementation mANADeleteScript

- (id)init
{
    if(self = [super init])
    {
        self.type = mANADeleteScriptType;
    }
    
    return self;
}

- (void)execute:(mAPlayerViewController *)player
{
    
}

@end

@implementation mANAAddShred

- (id)init
{
    if(self = [super init])
    {
        self.type = mANAAddShredType;
    }
    
    return self;
}

- (void)execute:(mAPlayerViewController *)player
{
    mAScriptPlayer *scriptPlayer = [player scriptPlayerForRemoteUUID:self.code_id];
    [scriptPlayer addShred:nil];
}

@end

@implementation mANAReplaceShred

- (id)init
{
    if(self = [super init])
    {
        self.type = mANAReplaceShredType;
    }
    
    return self;
}

- (void)execute:(mAPlayerViewController *)player
{
    mAScriptPlayer *scriptPlayer = [player scriptPlayerForRemoteUUID:self.code_id];
    [scriptPlayer replaceShred:nil];
}

@end

@implementation mANARemoveShred

- (id)init
{
    if(self = [super init])
    {
        self.type = mANARemoveShredType;
    }
    
    return self;
}

- (void)execute:(mAPlayerViewController *)player
{
    mAScriptPlayer *scriptPlayer = [player scriptPlayerForRemoteUUID:self.code_id];
    [scriptPlayer removeShred:nil];
}

@end

