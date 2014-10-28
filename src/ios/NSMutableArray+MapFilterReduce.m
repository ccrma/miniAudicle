//
//  NSMutableArray+MapFilterReduce.m
//  miniAudicle
//
//  Created by Spencer Salazar on 8/7/14.
//
//

#import "NSMutableArray+MapFilterReduce.h"

@implementation NSMutableArray (MapFilterReduce)

- (void)map:(void (^)(id))map
{
    for(id object in self)
        map(object);
}

- (void)filter:(BOOL (^)(id))filter
{
    NSMutableArray *filteredOut = [NSMutableArray new];
    
    for(id object in self)
    {
        if(filter(object))
            [filteredOut addObject:object];
    }
    
    [self removeObjectsInArray:filteredOut];
}

@end
