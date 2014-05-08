//
//  mAOTFButton.m
//  miniAudicle
//
//  Created by Spencer Salazar on 4/26/14.
//
//

#import "mAOTFButton.h"
#import "mACGContext.h"


@interface mAOTFButton ()
{
    BOOL _showHighlight;
    
    BOOL _poppedUp;
    mAOTFButton *_trackingPopup;
    
    UILabel *_textLabel;
}

@property (strong, nonatomic) NSTimer *popUpTimer;
@property (nonatomic) BOOL poppedUp;
@property (nonatomic) BOOL isPopup;
@property (weak, nonatomic) mAOTFButton *parent;

@end


@implementation mAOTFButton

- (void)setText:(NSString *)text
{
    _text = text;
    
    if(_textLabel == nil)
    {
        CGRect frame = self.bounds;
        frame.size.height /= 2;
        _textLabel = [[UILabel alloc] initWithFrame:frame];
        _textLabel.center = self.center;
        _textLabel.textAlignment = NSTextAlignmentRight;
        _textLabel.font = [UIFont systemFontOfSize:36];
        
        [self addSubview:_textLabel];
    }
    
    _textLabel.text = _text;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _showHighlight = NO;
        self.insets = UIEdgeInsetsZero;
        _trackingPopup = nil;
        self.isPopup = NO;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        _showHighlight = NO;
        self.insets = UIEdgeInsetsZero;
        _trackingPopup = nil;
        self.isPopup = NO;
    }
    return self;
}


- (void)collapse
{
    CGPoint target = self.center;
    
    for(mAOTFButton *button in self.alternatives)
    {
        [UIView animateWithDuration:1-G_RATIO
                         animations:^{
                             button.center = target;
                         } completion:^(BOOL finished) {
                             [button removeFromSuperview];
                         }];
    }
}


- (void)collapseToAlternative:(id)alternative
{
    CGPoint target = self.center;
    
    for(mAOTFButton *button in self.alternatives)
    {
        if(button == alternative)
        {
            [self.superview bringSubviewToFront:button];
            [UIView animateWithDuration:1-G_RATIO
                             animations:^{
                                 button.center = target;
                             }];
        }
        else
        {
            [UIView animateWithDuration:1-G_RATIO
                             animations:^{
                                 button.center = target;
                             } completion:^(BOOL finished) {
                                 [button removeFromSuperview];
                             }];
        }
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    [[UIColor lightGrayColor] set];
    
    CGContextAddRoundedRect(ctx, self.bounds, 8);
    CGContextClip(ctx);
    
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
    
    [self.image drawInRect:UIEdgeInsetsInsetRect(self.bounds, self.insets)];
    
    if(_showHighlight)
    {
        [[UIColor colorWithWhite:0.0 alpha:0.25] set];
        CGContextAddRoundedRect(ctx, self.bounds, 8);
        CGContextFillPath(ctx);
    }
}


- (void)popUp:(NSTimer *)timer
{
    self.poppedUp = YES;
    _trackingPopup = nil;
    
    [self.superview bringSubviewToFront:self];
    
    int i = 0;
    
    for(mAOTFButton *button in self.alternatives)
    {
//        [button removeFromSuperview];
        button.center = self.center;
        button.isPopup = YES;
        button.parent = self;
        
        if(button.superview == nil)
            [self.superview insertSubview:button belowSubview:self];
        
        CGPoint target;
        float margin = 4;
        switch(i)
        {
            case 0:
                // left side
                target = CGPointMake(self.center.x - self.frame.size.width/2 - button.frame.size.width/2 - margin,
                                     self.center.y);
                break;
                
            case 1:
                // right side
                target = CGPointMake(self.center.x + self.frame.size.width/2 + button.frame.size.width/2 + margin,
                                     self.center.y);
                break;
                
            case 2:
                // bottom side
                target = CGPointMake(self.center.x,
                                     self.center.y + self.frame.size.height/2 + button.frame.size.height/2 + margin);
                break;
                
            case 3:
                // top side
                target = CGPointMake(self.center.x,
                                     self.center.y - self.frame.size.height/2 - button.frame.size.height/2 - margin);
                break;
                
            default:
                NSLog(@"warning: mAOTFButton with more than 4 alternatives");
                // ...
        }
        
        [UIView animateWithDuration:1-G_RATIO
                         animations:^{
                             button.center = target;
                         }];
        
        i++;
    }
}


- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.poppedUp = NO;
    _trackingPopup = nil;
    
    if(touch.phase == UITouchPhaseBegan || self.isPopup)
    {
        _showHighlight = YES;
        
        [self setNeedsDisplay];
        
        if(self.alternatives)
        {
            [self.popUpTimer invalidate];
            self.popUpTimer = nil;
            
            self.popUpTimer = [NSTimer scheduledTimerWithTimeInterval:0.8
                                                               target:self
                                                             selector:@selector(popUp:)
                                                             userInfo:nil
                                                              repeats:NO];
        }
        else if(self.parent != nil && !self.parent.poppedUp)
        {
            [self.popUpTimer invalidate];
            self.popUpTimer = nil;
            
            self.popUpTimer = [NSTimer scheduledTimerWithTimeInterval:0.8
                                                               target:self.parent
                                                             selector:@selector(popUp:)
                                                             userInfo:nil
                                                              repeats:NO];
        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self.popUpTimer invalidate];
    self.popUpTimer = nil;

    BOOL wasHighlighted = _showHighlight;

    if(CGRectContainsPoint(self.bounds, [touch locationInView:self]))
        _showHighlight = YES;
    else
        _showHighlight = NO;

    if(_poppedUp && (_trackingPopup != nil || !_showHighlight))
    {
        for(mAOTFButton *button in self.alternatives)
        {
            if(CGRectContainsPoint(button.bounds, [touch locationInView:button]))
            {
                if(_trackingPopup == button)
                {
                    [button continueTrackingWithTouch:touch withEvent:event];
                }
                else
                {
                    [_trackingPopup endTrackingWithTouch:touch withEvent:event];
                    _trackingPopup = button;
                    [button beginTrackingWithTouch:touch withEvent:event];
                }
            }
            else if(_trackingPopup == button)
            {
                [_trackingPopup endTrackingWithTouch:touch withEvent:event];
            }
        }
    }
    
    if(wasHighlighted != _showHighlight)
        [self setNeedsDisplay];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self.popUpTimer invalidate];
    self.popUpTimer = nil;
    
    BOOL wasPressed = NO;
    
    if(self.isPopup && CGRectContainsPoint(self.bounds, [touch locationInView:self]))
    {
        // need to manually sendActions because of hacked touch tracking
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
        wasPressed = YES;
    }
    
    BOOL wasHighlighted = _showHighlight;
    
    _showHighlight = NO;
    
    if(wasHighlighted != _showHighlight)
        [self setNeedsDisplay];
    
    if(self.poppedUp)
    {
        self.poppedUp = NO;
        
        id alternative = nil;
        
        if(_trackingPopup != nil)
        {
            if(CGRectContainsPoint(_trackingPopup.bounds, [touch locationInView:_trackingPopup]))
            {
                alternative = _trackingPopup;
                wasPressed = YES;
            }
            
            [_trackingPopup endTrackingWithTouch:touch withEvent:event];
        }
        
        // only collapse if nothing was pressed
        // if something was pressed, receiver of press action triggers collapse
        if(!wasPressed)
            [self collapse];
        
//        if(alternative != nil)
//            [self collapseToAlternative:alternative];
//        else
//            [self collapse];
    }
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [self.popUpTimer invalidate];
    self.popUpTimer = nil;
    
    BOOL wasHighlighted = _showHighlight;
    
    _showHighlight = NO;
    
    if(wasHighlighted != _showHighlight)
        [self setNeedsDisplay];
    
    if(self.alternatives)
    {
        for(mAOTFButton *button in self.alternatives)
        {
            [button removeFromSuperview];
        }
    }
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    if(CGRectContainsPoint(self.bounds, [[[event touchesForView:self] anyObject] locationInView:self]))
        [super sendAction:action to:target forEvent:event];
}


@end
