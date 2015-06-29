//
//  mAFileNavigationController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 1/7/15.
//
//

#import <UIKit/UIKit.h>

@class mAFileViewController;
@class mADetailViewController;

@interface mAFileNavigationController : UIViewController < UINavigationControllerDelegate >

@property (strong, nonatomic) mADetailViewController *detailViewController;

@end
