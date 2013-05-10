//
//  NSView+Subsume.m
//  miniAudicle
//
//  Created by Spencer Salazar on 5/9/13.
//
//

#import "NSView+Subsume.h"

@implementation NSView (Subsume)

- (void)subsumeView:(NSView *)view animate:(BOOL)animate
{
    [view removeFromSuperview];
    
    self.frame = NSUnionRect([self frame], [view frame]);
}

@end
