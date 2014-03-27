//
//  mARoundedRectButton.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import "mARoundedRectButton.h"
#import "mACGContext.h"


@implementation mARoundedRectButton

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
    
    CGContextAddRoundedRect(ctx, self.bounds, 8);
    CGContextClip(ctx);
    
    [[self titleColorForState:self.state] set];
    
    CGContextAddRoundedRect(ctx, self.bounds, 8);
    CGContextFillPath(ctx);
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 0.9,  // Start color
        1.0, 1.0, 1.0, 0.05 }; // End color
    
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
    
    CGPoint topCenter = CGPointMake(CGRectGetMidX(self.bounds), self.bounds.origin.y + self.bounds.size.height*1.5);
    CGContextDrawRadialGradient(ctx, glossGradient, topCenter, 0, topCenter, self.bounds.size.width*2, 0);
    
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    [self setNeedsDisplay];
}

@end


