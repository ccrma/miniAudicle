//
//  mATextCompletionView.m
//  miniAudicle
//
//  Created by Spencer Salazar on 8/29/14.
//
//

#import "mATextCompletionView.h"


#import "mACGContext.h"

//#define BUTTON_SIZE 48
#define BUTTON_HEIGHT 28
#define HMARGIN 8
#define VMARGIN 4

@interface mATextCompletionView ()
{
    int _selection;
}

@end

@implementation mATextCompletionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.completions = nil;
        self.textAttributes = nil;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        _selection = INT_MAX;
        _selectedCompletion = nil;
    }
    return self;
}

- (void)sizeToFit
{
    [super sizeToFit];
    [self setNeedsDisplay];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    NSDictionary *textAttributes;
    if(self.textAttributes)
        textAttributes = self.textAttributes;
    else
        textAttributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:20] };
    
    CGFloat maxWidth = 0;
    for(int i = 0; i < self.completions.count; i++)
    {
        NSString *str = [self.completions objectAtIndex:i];
        CGSize strSize = [str sizeWithAttributes:textAttributes];
        if(strSize.width > maxWidth)
            maxWidth = strSize.width;
    }
    
    return CGSizeMake(maxWidth+HMARGIN*2, self.completions.count*BUTTON_HEIGHT+VMARGIN*2);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // draw background
    [[UIColor whiteColor] set];
    CGContextAddRoundedRect(ctx, self.bounds, 8);
    CGContextFillPath(ctx);
    
    [[UIColor lightGrayColor] set];
    CGContextSetLineWidth(ctx, 0.5);
    CGContextAddRoundedRect(ctx, self.bounds, 8);
    CGContextStrokePath(ctx);
    
    NSDictionary *textAttributes;
    NSDictionary *selectionTextAttributes;
    
    if(self.textAttributes)
    {
        textAttributes = self.textAttributes;
        NSMutableDictionary *dict = [self.textAttributes mutableCopy];
        [dict setObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
        selectionTextAttributes = dict;
    }
    else
    {
        textAttributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:20] };
        selectionTextAttributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:20],
                                     NSForegroundColorAttributeName: [UIColor whiteColor] };
    }
    
    for(int i = 0; i < self.completions.count; i++)
    {
        CGRect rect = CGRectMake(HMARGIN, VMARGIN+(VMARGIN+BUTTON_HEIGHT)*i, self.bounds.size.width-HMARGIN*2, BUTTON_HEIGHT);
        NSDictionary *attributes = textAttributes;
        
        if(_selection == i)
        {
            CGRect selectRect = CGRectMake(HMARGIN/2, VMARGIN+(VMARGIN+BUTTON_HEIGHT)*i, self.bounds.size.width-HMARGIN, BUTTON_HEIGHT);
            [[UIColor colorWithRed:0.05 green:0.55 blue:0.97 alpha:1] set];
            CGContextAddRoundedRect(ctx, selectRect, 4);
            CGContextFillPath(ctx);
            
            attributes = selectionTextAttributes;
        }
        
        NSString *str = [self.completions objectAtIndex:i];
        CGSize strSize = [str sizeWithAttributes:attributes];
        // h-align left, v-align center
        [str drawInRect:CGRectMake(rect.origin.x, rect.origin.y+rect.size.height/2-strSize.height/2,
                                   strSize.width, strSize.height)
         withAttributes:attributes];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _selectedCompletion = nil;
    
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self];
    
    BOOL noSelection = YES;
    for(int i = 0; i < self.completions.count; i++)
    {
        CGRect rect = CGRectMake(HMARGIN, VMARGIN+(VMARGIN+BUTTON_HEIGHT)*i, self.bounds.size.width-HMARGIN*2, BUTTON_HEIGHT);
        if(CGRectContainsPoint(rect, loc))
        {
            _selection = i;
            [self setNeedsDisplay];
            noSelection = NO;
            break;
        }
    }
    
    if(noSelection)
    {
        [self setNeedsDisplay];
        _selection = INT_MAX;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self];
    
    BOOL noSelection = YES;
    for(int i = 0; i < self.completions.count; i++)
    {
        CGRect rect = CGRectMake(HMARGIN, VMARGIN+(VMARGIN+BUTTON_HEIGHT)*i, self.bounds.size.width-HMARGIN*2, BUTTON_HEIGHT);
        if(CGRectContainsPoint(rect, loc))
        {
            _selection = i;
            [self setNeedsDisplay];
            noSelection = NO;
            break;
        }
    }
    
    if(noSelection)
    {
        [self setNeedsDisplay];
        _selection = INT_MAX;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if(_selection != INT_MAX)
    {
        _selectedCompletion = [self.completions objectAtIndex:_selection];
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        [self setNeedsDisplay];
    }
    
    _selection = INT_MAX;
}


@end
