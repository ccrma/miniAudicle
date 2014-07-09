//
//  mAKeyboardButton.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/24/14.
//
//

#import "mAKeyboardButton.h"
#import "mAKeyboardButtonAlternatives.h"
#import "mACGContext.h"


#define POP_OPEN_TIME (G_RATIO-1)


@interface mAKeyboardButton ()

@property (strong, nonatomic) NSTimer *popOpenTimer;
@property (strong, nonatomic) mAKeyboardButtonAlternatives *alternativesView;
@property (strong, nonatomic) NSMutableArray *targets;

@end


@implementation mAKeyboardButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _pressedKey = [self titleForState:UIControlStateNormal];
        self.targets = [NSMutableArray new];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self == [super initWithCoder:aDecoder])
    {
        _pressedKey = [self titleForState:UIControlStateNormal];
        self.targets = [NSMutableArray new];
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
        [[UIColor groupTableViewBackgroundColor] set];
    }
    
    CGContextSetLineWidth(ctx, 2);
    CGContextAddRoundedRect(ctx, self.bounds, 8);
    CGContextFillPath(ctx);
}

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [self.targets addObject:target];
    [super addTarget:target action:action forControlEvents:controlEvents];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents
{
    [super removeTarget:target action:action forControlEvents:controlEvents];
    [self.targets removeObject:target];
}

- (void)popOpen:(NSTimer *)timer
{
    [self.alternativesView removeFromSuperview];
    self.alternativesView = nil;
    
    self.alternativesView = [[mAKeyboardButtonAlternatives alloc] initWithAlternatives:self.alternatives];
    self.alternativesView.attributes = self.attributes;
    
    CGPoint center = CGPointMake(self.center.x,
                                 self.center.y - self.frame.size.height/2 - 4 - self.alternativesView.frame.size.height/2);
    if(center.x + self.alternativesView.frame.size.width > self.superview.bounds.origin.x + self.superview.bounds.size.width)
        // if pushes over right edge, move to align right edges
        center.x = self.center.x - self.alternativesView.frame.size.width/2 + self.frame.size.width/2 + 1;
    // TODO: below
//    else if(center.x + self.alternativesView.frame.size.width > self.superview.bounds.origin.x + self.superview.bounds.size.width)
//        // if pushes over left edge, move to align left edges
//        center.x = self.center.x - self.alternativesView.frame.size.width + self.frame.size.width/2;
    
    self.alternativesView.center = center;
    
    for(id target in self.targets)
    {
        NSArray *selectors = [self actionsForTarget:target forControlEvent:UIControlEventTouchUpInside];
        for(NSString *selectorString in selectors)
        {
            [self.alternativesView addTarget:target
                                      action:NSSelectorFromString(selectorString)
                            forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    [self.superview addSubview:self.alternativesView];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.popOpenTimer invalidate];
    self.popOpenTimer = nil;

    [super touchesBegan:touches withEvent:event];
    
    [self setNeedsDisplay];
    
    if(self.alternatives)
    {
        self.popOpenTimer = [NSTimer scheduledTimerWithTimeInterval:POP_OPEN_TIME
                                                             target:self
                                                           selector:@selector(popOpen:)
                                                           userInfo:nil
                                                            repeats:NO];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.popOpenTimer invalidate];
    self.popOpenTimer = nil;
    
    if(self.alternativesView)
    {
        [self.alternativesView touchesMoved:touches withEvent:event];
    }
    else
    {
        [super touchesMoved:touches withEvent:event];
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.popOpenTimer invalidate];
    self.popOpenTimer = nil;
    
    if(self.alternativesView)
    {
        [self.alternativesView touchesEnded:touches withEvent:event];

        [self.alternativesView removeFromSuperview];
        self.alternativesView = nil;
    }

    [super touchesEnded:touches withEvent:event];
    
    [self setNeedsDisplay];
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if(CGRectContainsPoint(self.bounds, [[[event touchesForView:self] anyObject] locationInView:self]))
        [super sendAction:action to:target forEvent:event];
}


@end



