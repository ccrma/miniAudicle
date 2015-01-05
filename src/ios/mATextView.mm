//
//  mATextView.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/24/14.
//
//

#import "mATextView.h"

#define LINENUM_LEFTMARGIN (8)
#define LINENUM_RIGHTMARGIN (8)


@interface mATextView ()
{
    UIView *_imageView;
    
    float _lineNumbersWidth;
    float _lineNumbersHeightPerLine;
}

@property (nonatomic, strong) UIFont *lineNumberFont;

- (void)updateLineNumbers;
- (void)animateImage:(UIImage *)image atLocation:(CGPoint)location;
- (void)animateImage:(UIImage *)image atLocation:(CGPoint)location size:(CGSize)size;

- (void)drawLineNumbersInRect:(CGRect)rect;
- (void)drawLineNumber:(int)num forLineRect:(CGRect)rect;

@end


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

- (void)initCommon
{
    // Initialization code
    self.errorLine = -1;
    self.contentMode = UIViewContentModeRedraw;
    _lineNumbersWidth = 0;
    self.lineNumberFont = [UIFont fontWithName:@"Menlo" size:10];
    [self updateLineNumbers];
    _lineNumbersHeightPerLine = self.font.lineHeight;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initCommon];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (NSDictionary *)errorTextAttributes
{
    return @{ NSFontAttributeName: [UIFont fontWithName:@"Menlo" size:12] };
}

- (UIColor *)errorColor
{
    return [UIColor colorWithRed:1 green:0.45 blue:0.45 alpha:1];
}

- (NSDictionary *)lineNumberTextAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentRight;
    return @{ NSFontAttributeName: self.lineNumberFont,
              NSParagraphStyleAttributeName: paragraphStyle,
              NSForegroundColorAttributeName: [UIColor colorWithWhite:0.5 alpha:1] };
}

- (void)updateLineNumbers
{
    float lineNumbersWidth = LINENUM_LEFTMARGIN + [@"00000" sizeWithAttributes:[self lineNumberTextAttributes]].width + LINENUM_RIGHTMARGIN;
    if(_lineNumbersWidth != lineNumbersWidth)
    {
        _lineNumbersWidth = lineNumbersWidth;
        UIEdgeInsets insets = self.textContainerInset;
        insets.left += _lineNumbersWidth;
        self.textContainerInset = insets;
    }
}

- (void)animateImage:(UIImage *)image atLocation:(CGPoint)location
{
    [self animateImage:image atLocation:location size:image.size];
}

- (void)animateImage:(UIImage *)image atLocation:(CGPoint)location size:(CGSize)size
{
    [_imageView removeFromSuperview];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.frame.size = size;
    imageView.center = location;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    imageView.clipsToBounds = YES;
    imageView.image = image;
    [self addSubview:imageView];
    _imageView = imageView;
    
    [UIView animateWithDuration:1
                     animations:^{
                         imageView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [imageView removeFromSuperview];
                         if(imageView == _imageView)
                         {
                             _imageView = nil;
                         }
                     }];
}

- (void)animateAdd
{
    [self animateImage:[UIImage imageNamed:@"add.png"]
            atLocation:CGPointMake(self.center.x, self.bounds.origin.y + self.bounds.size.width*(1-(G_RATIO-1)))
                  size:CGSizeMake(300, 300)];
}

- (void)animateReplace
{
    [self animateImage:[UIImage imageNamed:@"replace.png"]
            atLocation:CGPointMake(self.center.x, self.bounds.origin.y + self.bounds.size.width*(1-(G_RATIO-1)))
                  size:CGSizeMake(300, 300)];
}

- (void)animateRemove
{
    [self animateImage:[UIImage imageNamed:@"remove.png"]
            atLocation:CGPointMake(self.center.x, self.bounds.origin.y + self.bounds.size.width*(1-(G_RATIO-1)))
                  size:CGSizeMake(300, 300)];
}

- (void)animateError
{
    [self animateImage:[UIImage imageNamed:@"error.png"]
            atLocation:CGPointMake(self.bounds.origin.x + self.bounds.size.width*0.9,
                                   self.bounds.origin.y + self.bounds.size.width*0.1)
                  size:CGSizeMake(125, 125)];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
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
        
//        [[self errorColor] set];
//        CGContextFillPath(ctx);
        
        /* draw superview */
        [super drawRect:rect];
        
        if(self.errorMessage)
        {
//            CGContextSetBlendMode(ctx, kCGBlendModeDestinationAtop);
            
            CGContextAddRect(ctx, CGRectMake(xStart, yStart, xSize, ySize));

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
    
    /* draw gutter */
    
    CGRect ixRect = CGRectIntersection(rect, CGRectMake(self.contentOffset.x, self.contentOffset.y, _lineNumbersWidth, self.bounds.size.height));
    [[UIColor colorWithWhite:0.83 alpha:1] set];
    CGContextFillRect(ctx, ixRect);
    
//    int lineStart = floorf(rect.origin.y/_lineNumbersHeightPerLine);
//    int lineEnd = ceilf((rect.origin.y+rect.size.height)/_lineNumbersHeightPerLine);
    
    [self drawLineNumbersInRect:rect];
}

- (void)drawLineNumbersInRect:(CGRect)rect
{
    NSLayoutManager *layoutManager = self.layoutManager;
    NSTextContainer *textContainer = self.textContainer;
    
    // Find the glyph range for the visible glyphs
    NSRange glyphRange = [layoutManager glyphRangeForBoundingRect:rect inTextContainer:textContainer];
    
    // Calculate the start and end indexes for the glyphs
    unsigned startGlyphIndex = glyphRange.location;
    unsigned endGlyphIndex = glyphRange.location + glyphRange.length;
    
    int index = 0;
    int lineNumber = 1;
    
    // Skip all lines that are visible at the top of the text view (if any)
    NSRange lineRange;
    CGRect lineRect;
    while(index < startGlyphIndex)
    {
        lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
        index = NSMaxRange( lineRange );
        ++lineNumber;
    }
    
    for(index = startGlyphIndex; index < endGlyphIndex; lineNumber++)
    {
        lineRect = [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
        index = NSMaxRange(lineRange);
        [self drawLineNumber:lineNumber forLineRect:lineRect];
    }
    
    lineRect = [layoutManager extraLineFragmentRect];
    if(lineRect.size.width != 0 && lineRect.size.height != 0)
    {
        [self drawLineNumber:lineNumber forLineRect:lineRect];
    }
}

- (void)drawLineNumber:(int)num forLineRect:(CGRect)lineRect
{
    NSString *lineString = [NSString stringWithFormat:@"%i", num];
    
    CGRect numberRect = lineRect;
    numberRect.origin.y += self.textContainerInset.top + (self.font.lineHeight-self.lineNumberFont.lineHeight)*0.9;
    numberRect.origin.x = LINENUM_LEFTMARGIN;
    numberRect.size.width = _lineNumbersWidth-(LINENUM_LEFTMARGIN+LINENUM_RIGHTMARGIN);
    [lineString drawInRect:numberRect
            withAttributes:[self lineNumberTextAttributes]];
}

@end


