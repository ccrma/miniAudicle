//
//  NSObject+KVCSerialization.m
//  miniAudicle
//
//  Created by Spencer Salazar on 8/5/14.
//
//

#import "NSObject+KVCSerialization.h"
#import "objc/runtime.h"

@implementation NSObject (KVCSerialization)

- (id)initWithDictionary:(NSDictionary *)dict
{
    if(self = [self init])
    {
        for(NSString *key in dict)
        {
            if([self keyExists:key])
                [self setValue:[dict objectForKey:key] forKey:key];
        }
    }
    
    return self;
}

- (NSDictionary *)asDictionary
{
    NSMutableDictionary *dict = [NSMutableDictionary new];
    for(NSString *key in [self keys])
    {
        id object = [self valueForKey:key];
        if(object != nil)
            [dict setObject:object forKey:key];
    }
    return dict;
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

- (NSArray *)keys
{
    NSMutableArray *array = [NSMutableArray new];
    
    // see http://stackoverflow.com/questions/780897/how-do-i-find-all-the-property-keys-of-a-kvc-compliant-objective-c-object
    unsigned int outCount, i;
    
    for(Class c = [self class]; c != [NSObject class]; c = [c superclass])
    {
        objc_property_t *properties = class_copyPropertyList(c, &outCount);
        for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
            const char *propName = property_getName(property);
            if(propName) {
                NSString *propertyName = [NSString stringWithUTF8String:propName];
                [array addObject:propertyName];
            }
        }
        free(properties);
    }
    
    return array;
}

@end


