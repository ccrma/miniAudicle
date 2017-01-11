//
//  NSPanel+ButtonTag.h
//  miniAudicle
//
//  Created by leanne on 1/11/17.
//
//

#import <AppKit/AppKit.h>

@interface NSPanel (ButtonTag)

- (int)tagForButtonWithTitle:(NSString *)title;
- (void)setTag:(int)tagValue forButtonWithTitle:(NSString *)title;

@end
