//
//  mAScriptPlayerView.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/30/14.
//
//

#import "mAScriptPlayerView.h"

@implementation mAScriptPlayerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if(view == self)
        return nil;
    return view;
}

@end
