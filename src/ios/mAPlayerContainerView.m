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

- (void)addTapListener:(UIViewController<mATapOutsideListener> *)tapListener
{
    [self.tapListeners addObject:@{ @"listener": tapListener, @"views": @[tapListener] }];
}

- (void)addTapListener:(UIViewController<mATapOutsideListener> *)tapListener
    forTapOutsideViews:(NSArray *)views
{
    [self.tapListeners addObject:@{ @"listener": tapListener, @"views": views }];
}

- (void)removeTapListener:(UIViewController<mATapOutsideListener> *)tapListener
{
    NSDictionary *removeDict = nil;
    for(NSDictionary *dict in self.tapListeners)
    {
        if([dict objectForKey:@"listener"] == tapListener)
        {
            removeDict = dict;
            break;
        }
    }
    
    if(removeDict != nil)
        [self.tapListeners removeObject:removeDict];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    
    if(hitView != nil)
    {
        [self.tappedOutside removeAllObjects];
        
        for(NSDictionary *dict in self.tapListeners)
        {
            BOOL tapOutside = YES;
            
            for(id object in [dict objectForKey:@"views"])
            {
                UIView *view;
                if([object isKindOfClass:[UIViewController class]])
                    view = [object view];
                else if([object isKindOfClass:[UIView class]])
                    view = object;
                
                if([hitView isDescendantOfView:view])
                {
                    tapOutside = NO;
                    break;
                }
            }
            
            if(tapOutside)
                [self.tappedOutside addObject:[dict objectForKey:@"listener"]];
        }
        
        for(UIViewController<mATapOutsideListener> *viewController in self.tappedOutside)
            [viewController tapOutside];
        [self.tappedOutside removeAllObjects];
    }
    
    return hitView;
}

@end
