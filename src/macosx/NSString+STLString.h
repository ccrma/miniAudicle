//
//  NSObject+STLString.h
//  miniAudicle
//
//  Created by Spencer Salazar on 5/1/13.
//
//

#import <Foundation/Foundation.h>
#include <string>

@interface NSString (STLString)

- (std::string)stlString;

@end
