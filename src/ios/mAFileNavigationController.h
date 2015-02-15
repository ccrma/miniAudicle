//
//  mAFileNavigationController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 1/7/15.
//
//

#import <UIKit/UIKit.h>

@interface mAFileNavigationController : UIViewController < UINavigationControllerDelegate >

@property (strong, nonatomic) UINavigationController *childNavigationController;

@property (strong, nonatomic) UIViewController *myScriptsViewController;
@property (strong, nonatomic) UIViewController *examplesViewController;

@end
