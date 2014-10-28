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
    CGPoint _initialTouchPosition;
    BOOL _highlightedForSequencing;
}

@end

@implementation mAScriptPlayerTab

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _highlightedForSequencing = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        _highlightedForSequencing = NO;
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
    
    if(self.tintAdjustmentMode == UIViewTintAdjustmentModeDimmed)
    {
        CGContextAddRoundedRect(ctx, self.bounds, 10);
        [[self.superview.tintColor colorWithAlphaComponent:0.5] set];
        CGContextFillPath(ctx);
    }
    
    CGContextRestoreGState(ctx);
    
    if(_highlightedForSequencing)
    {
        float offset = 0;
        float widthFactor = 0.17;
        
        CGRect bounds1 = self.bounds, bounds2 = self.bounds;
        bounds1.size.width *= widthFactor;
        bounds2.origin.x += bounds2.size.width*(1-widthFactor);
        bounds2.size.width *= widthFactor;
        
        CGContextAddRect(ctx, bounds1);
        CGContextAddRect(ctx, bounds2);
        CGContextClip(ctx);
        
        [[UIColor yellowColor] set];
        CGContextAddRoundedRect(ctx, self.bounds, 10);
        CGContextSetLineWidth(ctx, 4);
        CGContextStrokePath(ctx);
    }
}

- (void)tintColorDidChange
{
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.sequenceMode)
    {
        _highlightedForSequencing = YES;
        [self setNeedsDisplay];
    }
    else
    {
    }

    _initialTouchPosition = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL wasHighlightedForSequencing = _highlightedForSequencing;
    _highlightedForSequencing = NO;
    
    if(self.sequenceMode)
    {
        CGPoint touchPosition = [[touches anyObject] locationInView:self];
        if(CGRectContainsPoint(self.bounds, touchPosition))
            _highlightedForSequencing = YES;
        else
            _highlightedForSequencing = NO;
    }
    else
    {
        CGPoint touchPosition = [[touches anyObject] locationInView:self];
        self.superview.center = CGPointMake(self.superview.center.x + (touchPosition.x - _initialTouchPosition.x),
                                            self.superview.center.y + (touchPosition.y - _initialTouchPosition.y));
        
        [self.playerViewController playerTabMoved:self];
    }
    
    if(wasHighlightedForSequencing != _highlightedForSequencing)
        [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL wasHighlightedForSequencing = _highlightedForSequencing;
    _highlightedForSequencing = NO;
    
    if(self.sequenceMode)
    {
        CGPoint touchPosition = [[touches anyObject] locationInView:self];
        if(CGRectContainsPoint(self.bounds, touchPosition))
        {
            [self.scriptPlayer playerTabEvent:UIControlEventTouchUpInside];
        }
    }
    else
    {
        [self.scriptPlayer playerTabFinishedMoving];
    }
    
    if(wasHighlightedForSequencing != _highlightedForSequencing)
        [self setNeedsDisplay];
}

@end
