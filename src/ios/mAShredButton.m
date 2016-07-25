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
    // CGFloat leadAngle = -M_PI*0.5f + 2.0f*M_PI*(t/60.0f);

    CGContextAddEllipseInRect(ctx, self.bounds);
    CGContextClip(ctx);
    
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    
//    [[self titleColorForState:self.state] set];
    
//    [[UIColor whiteColor] set];
    
//    CGContextAddEllipseInRect(ctx, self.bounds);
//    CGContextFillPath(ctx);
    
//    CGContextBeginPath(ctx);
//    CGContextMoveToPoint(ctx, center.x, center.y);
//    CGContextAddArc(ctx, center.x, center.y, radius, leadAngle, leadAngle+M_PI*0.5f, 1);
//    CGContextClosePath(ctx);
//    CGContextClip(ctx);
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
//    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.05,  // Start color
//        0.1, 0.9, 0.1, 0.9 }; // End color
    CGFloat components[8] = { 0.25, 0.9, 0.25, 0.9,  // Start color
        0.25, 0.9, 0.25, 0.00 }; // End color
    
//    [[UIColor colorWithRed:0.1 green:0.9 blue:0.1 alpha:0.25] set];
//    CGContextAddEllipseInRect(ctx, self.bounds);
//    CGContextFillPath(ctx);
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    float rate = 0.5;
    float scale = (0.5*(1+sinf(2*M_PI*t*rate)));
    radius = (0.7+scale);
    float inner = 0.65*self.bounds.size.width*0.4;
    float outer = radius*self.bounds.size.width*0.4;
    CGContextDrawRadialGradient(ctx, glossGradient, center, inner,
                                center, outer, kCGGradientDrawsBeforeStartLocation);
    
    CGContextSetBlendMode(ctx, kCGBlendModePlusLighter);
    
    CGContextDrawRadialGradient(ctx, glossGradient, center, inner,
                                center, outer, kCGGradientDrawsBeforeStartLocation);
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
    
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    
//    CGContextRestoreGState(ctx);
}


@end
