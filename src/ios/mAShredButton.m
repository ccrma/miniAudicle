//
//  mAShredButton.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/31/14.
//
//

#import "mAShredButton.h"


@interface mAShredButton ()
{
    float t;
    CFTimeInterval _lastTime;
}

@property (strong, nonatomic) NSTimer *timer;

- (void)update:(NSTimer *)timer;

@end


@implementation mAShredButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f/30.0f
                                                      target:self
                                                    selector:@selector(update:)
                                                    userInfo:nil
                                                     repeats:YES];
        _lastTime = CACurrentMediaTime();
    }
    return self;
}


- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)update:(NSTimer *)timer
{
    CFTimeInterval now = CACurrentMediaTime();
    t += now - _lastTime;
    _lastTime = CACurrentMediaTime();
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = self.bounds.size.width/2;
    CGFloat leadAngle = -M_PI*0.5f + 2.0f*M_PI*(t/60.0f);

    CGContextAddEllipseInRect(ctx, self.bounds);
    CGContextClip(ctx);
    
//    [[self titleColorForState:self.state] set];
    
    [[UIColor whiteColor] set];
    
    CGContextAddEllipseInRect(ctx, self.bounds);
    CGContextFillPath(ctx);
    
//    CGContextBeginPath(ctx);
//    CGContextMoveToPoint(ctx, center.x, center.y);
//    CGContextAddArc(ctx, center.x, center.y, radius, leadAngle, leadAngle+M_PI*0.5f, 1);
//    CGContextClosePath(ctx);
//    CGContextClip(ctx);
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.05,  // Start color
        0.1, 0.9, 0.1, 0.9 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGContextDrawRadialGradient(ctx, glossGradient, center, 0,
                                center, (0.5*(1+sinf(2*M_PI*t*0.5))+0.1)*self.bounds.size.width*0.4, kCGGradientDrawsAfterEndLocation);
//    CGContextDrawRadialGradient(ctx, glossGradient, center, 0,
//                                center, (1.1)*self.bounds.size.width*0.4, kCGGradientDrawsAfterEndLocation);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    
    if(self.state == UIControlStateHighlighted)
    {
        [[UIColor colorWithWhite:0.0 alpha:0.25] set];
        CGContextAddEllipseInRect(ctx, self.bounds);
        CGContextFillPath(ctx);
    }
    
//    CGContextRestoreGState(ctx);
}


@end
