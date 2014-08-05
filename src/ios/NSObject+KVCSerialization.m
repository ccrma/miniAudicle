//
//  NSObject+KVCSerialization.m
//  miniAudicle
//
//  Created by Spencer Salazar on 8/5/14.
//
//

#import "NSObject+KVCSerialization.h"

@implementation NSObject (KVCSerialization)

- (id)initWithDictionary:(NSDictionary *)dict
{
    for(NSString *key in dict)
    {
        if([self keyExists:key])
            [self setValue:[dict objectForKey:key] forKey:key];
    }
    
    return self;
}

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
