//
//  mANetworkAction.m
//  miniAudicle
//
//  Created by Spencer Salazar on 4/13/14.
//
//

#import "mANetworkAction.h"

@interface NSObject (KeyValueCodingKeyExists)

- (BOOL)keyExists:(NSString *)key;

@end

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
    NSString *type = [[object objectForKey:@"type"] stringValue];
    
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
                [self setValue:object forKey:key];
        }
    }
    
    return self;
}

- (void)execute:(mAPlayerViewController *)player
{
    // no-op
}

@end


@implementation NSObject (KeyValueCodingKeyExists)

- (BOOL)keyExists:(NSString *)key
{
    @try {
        [self valueForKey:key];
    }
    @catch(NSException *exception) {
        return NO;
    }
    
    return YES;
}

@end

@implementation mANAJoinRoom
@end

@implementation mANALeaveRoom
@end

@implementation mANANewScript
@end

@implementation mANADeleteScript
@end

@implementation mANAAddShred
@end

@implementation mANAReplaceShred
@end

@implementation mANARemoveShred
@end

