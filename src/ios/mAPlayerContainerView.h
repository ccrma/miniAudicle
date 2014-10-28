//
//  mAPlayerContainerView.h
//  miniAudicle
//
//  Created by Spencer Salazar on 8/14/14.
//
//

#import <UIKit/UIKit.h>

@protocol mATapOutsideListener <NSObject>

- (void)tapOutside;

@end

@interface mAPlayerContainerView : UIView

- (void)addTapListener:(UIViewController<mATapOutsideListener> *)tapListener;

// views can be array of viewcontrollers, views, or both
- (void)addTapListener:(UIViewController<mATapOutsideListener> *)tapListener
    forTapOutsideViews:(NSArray *)views;
- (void)removeTapListener:(UIViewController<mATapOutsideListener> *)tapListener;

@end
