//
//  User.h
//  chuckpad-social-ios
//
//  Created by Mark Cerqueira on 6/21/16.
//
//

#ifndef User_h
#define User_h

// TODO Use this or remove it
@interface User : NSObject

@property(nonatomic, assign) NSInteger userId;
@property(nonatomic, retain) NSString *username;
@property(nonatomic, retain) NSString *email;
@property(nonatomic, assign) BOOL isAdmin;

- (User *)initWithDictionary:(NSDictionary *)dictionary;

- (NSString *)description;

@end

#endif /* User_h */
