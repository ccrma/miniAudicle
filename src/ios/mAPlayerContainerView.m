//
//  mAPlayerContainerView.m
//  miniAudicle
//
//  Created by Spencer Salazar on 8/14/14.
//
//

#import "mAPlayerContainerView.h"

@interface mAPlayerContainerView ()

@property (strong, nonatomic) NSMutableArray *tapListeners;
@property (strong, nonatomic) NSMutableArray *tappedOutside;

@end

@implementation mAPlayerContainerView

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.tapListeners = [NSMutableArray new];
        self.tappedOutside = [NSMutableArray new];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        self.tapListeners = [NSMutableArray new];
        self.tappedOutside = [NSMutableArray new];
    }
    
    return self;
}

- (void)addTapListener:(UIView<mATapOutsideListener> *)tapListener
{
    [self.tapListeners addObject:tapListener];
}

- (void)removeTapListener:(UIView<mATapOutsideListener> *)tapListener
{
    [self.tapListeners removeObject:tapListener];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if(hitView != nil)
    {
        [self.tappedOutside removeAllObjects];
        for(UIViewController<mATapOutsideListener> *viewController in self.tapListeners)
        {
            if(![hitView isDescendantOfView:viewController.view])
                [self.tappedOutside addObject:viewController];
        }
        
        for(UIViewController<mATapOutsideListener> *viewController in self.tappedOutside)
            [viewController tapOutside];
        [self.tappedOutside removeAllObjects];
    }
    
    return hitView;
}

@end
