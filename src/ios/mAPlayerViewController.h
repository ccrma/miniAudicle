//
//  mAPlayerViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import <UIKit/UIKit.h>

#import "mADetailViewController.h"

@interface mAPlayerViewController : UIViewController <mADetailClient>

@property (strong, nonatomic) UIBarButtonItem *titleButton;

- (void)addScript:(mADetailItem *)script;

@end
