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

enum mANetworkAction_Type
{
    MANA_TYPE_NEWSCRIPT = 1,
    MANA_TYPE_DELETESCRIPT = 2,
    MANA_TYPE_ADDSHRED = 3,
    MANA_TYPE_REPLACESHRED = 4,
    MANA_TYPE_REMOVESHRED = 5,
};

@implementation mANetworkAction

+ (id)networkActionWithObject:(NSDictionary *)object
{
    enum mANetworkAction_Type type = [[object objectForKey:@"type"] intValue];
    
    switch(type)
    {
        case MANA_TYPE_ADDSHRED:
            return [[mAAddShredNetworkAction alloc] initWithObject:object];
            break;
    }
    
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

@implementation mAAddShredNetworkAction

+ (id)addShredNetworkActionWithCode:(NSString *)code
{
    mAAddShredNetworkAction *action = [mAAddShredNetworkAction new];
    action.type = MANA_TYPE_ADDSHRED;
    action.code = code;
    
    return action;
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
