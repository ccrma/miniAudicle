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
    
    CGFloat yStart = self.bounds.origin.y + [self.font lineHeight] * (self.errorLine - 1);
    CGFloat xStart = self.bounds.origin.x;
    CGFloat ySize = [self.font lineHeight];
    CGFloat xSize = self.bounds.size.width;

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


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(self.errorLine >= 1)
    {
        CGFloat yBufferEdge = 1;
        CGFloat yStart = self.bounds.origin.y + self.textContainerInset.top + [self.font lineHeight] * (self.errorLine - 1) - yBufferEdge;
        CGFloat xStart = self.bounds.origin.x;
        CGFloat ySize = [self.font lineHeight] + yBufferEdge*2;
        CGFloat xSize = self.bounds.size.width;
        
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        [[UIColor colorWithRed:1 green:0.1 blue:0.1 alpha:0.55] set];
        CGContextFillRect(ctx, CGRectMake(xStart, yStart, xSize, ySize));
    }
    
    [super drawRect:rect];
    
    // Drawing code
}

@end
