//
//  mATextView.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/24/14.
//
//

#import "mATextView.h"

@implementation mATextView

- (void)setErrorLine:(NSInteger)errorLine
{
    _errorLine = errorLine;
    
//    CGFloat yStart = self.bounds.origin.y + [self.font lineHeight] * (self.errorLine - 1);
//    CGFloat xStart = self.bounds.origin.x;
//    CGFloat ySize = [self.font lineHeight];
//    CGFloat xSize = self.bounds.size.width;
//
//    [self setNeedsDisplayInRect:CGRectMake(xStart, yStart, xSize, ySize)];
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.errorLine = -1;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.errorLine = -1;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (NSDictionary *)errorTextAttributes
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [UIFont fontWithName:@"Menlo" size:12], NSFontAttributeName,
            nil];
}

- (UIColor *)errorColor
{
    return [UIColor colorWithRed:1 green:0.45 blue:0.45 alpha:1];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(self.errorLine >= 1)
    {
        CGFloat yBufferEdge = 1;
        CGFloat xBufferEdge = 4;
        CGSize textSize;
        
        CGFloat yStart = -self.contentOffset.y + self.bounds.origin.y + self.textContainerInset.top + [self.font lineHeight] * (self.errorLine - 1) - yBufferEdge;
        CGFloat xStart = -self.contentOffset.x + self.bounds.origin.x;
        CGFloat ySize = [self.font lineHeight] + yBufferEdge*2;
        CGFloat xSize = self.bounds.size.width;
        
        CGFloat errorMsgBoxXStart;
        CGFloat errorMsgBoxYStart;
        CGFloat errorMsgBoxXSize;
        CGFloat errorMsgBoxYSize;
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGContextAddRect(ctx, CGRectMake(xStart, yStart, xSize, ySize));
        
        [[self errorColor] set];
        CGContextFillPath(ctx);
        
        /* draw superview */
        [super drawRect:rect];
        
        if(self.errorMessage)
        {
//            CGContextSetBlendMode(ctx, kCGBlendModeDestinationAtop);
            
            CGFloat curveLength = 20;
            textSize = [self.errorMessage sizeWithAttributes:[self errorTextAttributes]];
            
            errorMsgBoxXStart = xStart+xSize-textSize.width-xBufferEdge*2;
            errorMsgBoxYStart = yStart+ySize;
            errorMsgBoxXSize = textSize.width+xBufferEdge*2;
            errorMsgBoxYSize = textSize.height+yBufferEdge*2;
            
            CGContextAddRect(ctx, CGRectMake(errorMsgBoxXStart, errorMsgBoxYStart,
                                             errorMsgBoxXSize, errorMsgBoxYSize));
            
            CGFloat curveDist = 0.3f;
            
            CGContextMoveToPoint(ctx, errorMsgBoxXStart-curveLength, errorMsgBoxYStart);
            CGContextAddQuadCurveToPoint(ctx, errorMsgBoxXStart-curveLength*(1-curveDist), errorMsgBoxYStart,
                                         errorMsgBoxXStart-curveLength*0.5f, errorMsgBoxYStart+errorMsgBoxYSize/2);
            CGContextAddQuadCurveToPoint(ctx, errorMsgBoxXStart-curveLength*curveDist, errorMsgBoxYStart+errorMsgBoxYSize,
                                         errorMsgBoxXStart, errorMsgBoxYStart+errorMsgBoxYSize);
            CGContextAddLineToPoint(ctx, errorMsgBoxXStart, errorMsgBoxYStart);
            CGContextAddLineToPoint(ctx, errorMsgBoxXStart-curveLength, errorMsgBoxYStart);
            
            [[self errorColor] set];
            CGContextFillPath(ctx);
            
            [self.errorMessage drawInRect:CGRectMake(xStart+xSize-textSize.width-xBufferEdge*2, yStart+ySize,
                                                     textSize.width, textSize.height)
                           withAttributes:[self errorTextAttributes]];
        }
    }
    else
    {
        /* draw superview */

        [super drawRect:rect];
    }
}

@end
