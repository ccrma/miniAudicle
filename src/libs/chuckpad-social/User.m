//
//  User.m
//  chuckpad-social-ios
//
//  Created by Mark Cerqueira on 6/21/16.
//
//

#import <Foundation/Foundation.h>
#import "User.h"

@implementation User  {
    
@private
    NSInteger _userId;
    NSString *_username;
    NSString *_email;
    BOOL _isAdmin;
}

@synthesize userId = _userId;
@synthesize username = _username;
@synthesize email = _email;
@synthesize isAdmin = _isAdmin;

- (User *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        // TODO
    }
    
    return self;
}

- (NSString *)description {
    // TODO
    return @"";
}

@end