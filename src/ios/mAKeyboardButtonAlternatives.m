//
//  mAKeyboardButtonAlternatives.m
//  miniAudicle
//
//  Created by Spencer Salazar on 4/23/14.
//
//

#import "mAKeyboardButtonAlternatives.h"

#import "mACGContext.h"

#define BUTTON_SIZE 48
#define MARGIN 4

@interface mAKeyboardButtonAlternatives ()
{
    int _selection;
}

@end

@implementation mAKeyboardButtonAlternatives

- (id)initWithAlternatives:(NSArray *)alternatives
{
    int num = [alternatives count];
    float containerWidth = BUTTON_SIZE*num + MARGIN*(num+1);
    float containerHeight = BUTTON_SIZE + MARGIN*2;
    
    self = [super initWithFrame:CGRectMake(0, 0, containerWidth, containerHeight)];
    if (self) {
        self.alternatives = alternatives;
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
        _pressedKey = @"";
        _selection = INT_MAX;
    }
    return self;
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
    
    NSDictionary *textAttributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:20] };
    NSDictionary *selectionTextAttributes = @{ NSFontAttributeName: [UIFont boldSystemFontOfSize:20],
                                               NSForegroundColorAttributeName: [UIColor whiteColor] };
    
    for(int i = 0; i < self.alternatives.count; i++)
    {
        CGRect rect = CGRectMake(MARGIN+(MARGIN+BUTTON_SIZE)*i, MARGIN, BUTTON_SIZE, BUTTON_SIZE);
        NSDictionary *attributes = textAttributes;
        
        if(_selection == i)
        {
            [[UIColor colorWithRed:0.05 green:0.45 blue:0.95 alpha:1] set];
            CGContextAddRoundedRect(ctx, rect, 4);
            CGContextFillPath(ctx);
            
            attributes = selectionTextAttributes;
        }
        
        NSString *chr = [self.alternatives objectAtIndex:i];
        CGSize charSize = [chr sizeWithAttributes:textAttributes];
        // center in button area
        [chr drawInRect:CGRectMake(rect.origin.x+rect.size.width/2-charSize.width/2,
                                   rect.origin.y+rect.size.height/2-charSize.height/2,
                                   charSize.width, charSize.height)
         withAttributes:attributes];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self];
    
    BOOL noSelection = YES;
    for(int i = 0; i < self.alternatives.count; i++)
    {
        CGRect rect = CGRectMake(MARGIN+(MARGIN+BUTTON_SIZE)*i, MARGIN, BUTTON_SIZE, BUTTON_SIZE);
        if(CGRectContainsPoint(rect, loc))
        {
            _selection = i;
            [self setNeedsDisplay];
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
    for(int i = 0; i < self.alternatives.count; i++)
    {
        CGRect rect = CGRectMake(MARGIN+(MARGIN+BUTTON_SIZE)*i, MARGIN, BUTTON_SIZE, BUTTON_SIZE);
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
        _pressedKey = [self.alternatives objectAtIndex:_selection];
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        [self setNeedsDisplay];
    }
    
    _selection = INT_MAX;
}


@end
