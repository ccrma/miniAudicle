//
//  mAPlayerView.m
//  miniAudicle
//
//  Created by Spencer Salazar on 4/9/14.
//
//

#import "mAPlayerScrollView.h"

@implementation mAPlayerScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    if(view == self || view.superview == self)
        return NO;
    return YES;
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    if(view == self || view.superview == self)
        return YES;
    return NO;
}

@end
