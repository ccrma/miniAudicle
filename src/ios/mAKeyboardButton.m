//
//  mAKeyboardButton.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/24/14.
//
//

#import "mAKeyboardButton.h"
#import <CoreGraphics/CoreGraphics.h>


void CGContextAddRoundedRect(CGContextRef ctx, CGRect rect, CGFloat cornerRadius)
{
    CGContextMoveToPoint(ctx, rect.origin.x+cornerRadius, rect.origin.y);
    
    CGContextAddArcToPoint(ctx, rect.origin.x+rect.size.width, rect.origin.y,
                           rect.origin.x+rect.size.width, rect.origin.y+rect.size.height, cornerRadius);
    
    CGContextAddArcToPoint(ctx, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height,
                           rect.origin.x, rect.origin.y+rect.size.height, cornerRadius);
    
    CGContextAddArcToPoint(ctx, rect.origin.x, rect.origin.y+rect.size.height,
                           rect.origin.x, rect.origin.y, cornerRadius);
    
    CGContextAddArcToPoint(ctx, rect.origin.x, rect.origin.y,
                           rect.origin.x+rect.size.width, rect.origin.y, cornerRadius);
}

void CGContextStrokeRoundedRect(CGContextRef ctx, CGRect rect, CGFloat cornerRadius)
{
    CGContextAddRoundedRect(ctx, rect, cornerRadius);
    
    CGContextStrokePath(ctx);
}


@implementation mAKeyboardButton

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
    
    if(self.state == UIControlStateNormal)
    {
        [[UIColor whiteColor] set];
    }
    else
    {
//        [[UIColor blackColor] set];
        [[UIColor groupTableViewBackgroundColor] set];
    }
    
    CGContextSetLineWidth(ctx, 2);
//    CGContextAddRoundedRect(ctx, CGRectMake(self.bounds.origin.x+4, self.bounds.origin.y+4, self.bounds.size.width-8, self.bounds.size.height-8), 8);
    CGContextAddRoundedRect(ctx, self.bounds, 8);
//    CGContextAddRect(ctx, self.bounds);
    CGContextFillPath(ctx);
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

