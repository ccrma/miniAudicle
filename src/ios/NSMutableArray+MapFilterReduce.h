//
//  NSMutableArray+MapFilterReduce.h
//  miniAudicle
//
//  Created by Spencer Salazar on 8/7/14.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (MapFilterReduce)

- (void)map:(void (^)(id))map;
- (void)filter:(BOOL (^)(id))filter;

@end
