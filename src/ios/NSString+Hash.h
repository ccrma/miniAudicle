//
//  NSString+Hash.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/1/16.
//
//

#import <Foundation/Foundation.h>

@interface NSString (Hash)

- (NSData *)sha1;
- (NSData *)sha256;

- (NSString *)sha1String;
- (NSString *)sha256String;

@end
