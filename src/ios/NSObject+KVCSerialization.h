//
//  NSObject+KVCSerialization.h
//  miniAudicle
//
//  Created by Spencer Salazar on 8/5/14.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (KVCSerialization)

- (id)initWithDictionary:(NSDictionary *)dict;
- (BOOL)keyExists:(NSString *)key;

@end
