//
//  mAFileNavigationController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 1/7/15.
//
//

#import <UIKit/UIKit.h>

@class mAFileViewController;

@interface mAFileNavigationController : UIViewController < UINavigationControllerDelegate >

@property (strong, nonatomic) UINavigationController *childNavigationController;

@property (strong, nonatomic) mAFileViewController *myScriptsViewController;
@property (strong, nonatomic) mAFileViewController *recentViewController;
@property (strong, nonatomic) mAFileViewController *examplesViewController;

@end
