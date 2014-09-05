//
//  mAScriptPlayerTab.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import "mAScriptPlayerTab.h"
#import "mAPlayerViewController.h"
#import "mACGContext.h"
#import "mAScriptPlayer.h"

@interface mAScriptPlayerTab ()
{
    CGPoint _lastTouchPosition;
}

@end

@implementation mAScriptPlayerTab

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(ctx);
    
    CGContextAddRoundedRect(ctx, self.bounds, 10);
    
    CGContextClip(ctx);
    
    [self.tintColor set];
    
    CGContextAddRoundedRect(ctx, self.bounds, 10);
    
    CGContextFillPath(ctx);
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.35,  // Start color
        1.0, 1.0, 1.0, 0.06 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGRect currentBounds = self.bounds;
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
    CGContextDrawLinearGradient(ctx, glossGradient, topCenter, midCenter, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    
    CGContextRestoreGState(ctx);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _lastTouchPosition = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touchPosition = [[touches anyObject] locationInView:self];
    self.superview.center = CGPointMake(self.superview.center.x + (touchPosition.x - _lastTouchPosition.x),
                                        self.superview.center.y + (touchPosition.y - _lastTouchPosition.y));
    
    [self.playerViewController playerTabMoved:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.scriptPlayer playerTabFinishedMoving];
}

@end
