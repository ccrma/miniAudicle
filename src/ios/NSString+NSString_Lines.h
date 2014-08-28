//
//  NSString+NSString_Lines.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/24/14.
//
//

#import <Foundation/Foundation.h>

@interface NSString (NSString_Lines)

- (NSRange)rangeOfLine:(NSInteger)lineNumber;
- (NSInteger)indexOfPreviousNewline:(NSInteger)index;

@end
