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
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.errorLine = -1;
    }
    return self;
}

- (NSDictionary *)errorTextAttributes
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
            [UIFont systemFontOfSize:12], NSFontAttributeName,
            nil];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(self.errorLine >= 1)
    {
        CGFloat yBufferEdge = 1;
        CGFloat xBufferEdge = 1;
        CGSize textSize;
        
        CGFloat yStart = self.bounds.origin.y + self.textContainerInset.top + [self.font lineHeight] * (self.errorLine - 1) - yBufferEdge;
        CGFloat xStart = self.bounds.origin.x;
        CGFloat ySize = [self.font lineHeight] + yBufferEdge*2;
        CGFloat xSize = self.bounds.size.width;
        
        CGFloat errorMsgBoxXStart;
        CGFloat errorMsgBoxYStart;
        CGFloat errorMsgBoxXSize;
        CGFloat errorMsgBoxYSize;
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        if(self.errorMessage)
        {
            CGFloat curveLength = 20;
            textSize = [self.errorMessage sizeWithAttributes:[self errorTextAttributes]];
            
            errorMsgBoxXStart = xStart+xSize-textSize.width-xBufferEdge;
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
        }
        
        CGContextAddRect(ctx, CGRectMake(xStart, yStart, xSize, ySize));
        
        [[UIColor colorWithRed:1 green:0.1 blue:0.1 alpha:0.55] set];
        CGContextFillPath(ctx);
        
        if(self.errorMessage)
        {
            [self.errorMessage drawInRect:CGRectMake(xStart+xSize-textSize.width-xBufferEdge, yStart+ySize,
                                                     textSize.width, textSize.height)
                           withAttributes:[self errorTextAttributes]];
        }
    }
    
    [super drawRect:rect];
    
    // Drawing code
}

@end
