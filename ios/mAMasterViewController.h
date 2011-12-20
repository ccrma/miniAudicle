//
//  mAMasterViewController.h
//  miniAudicle iOS
//
//  Created by Spencer Salazar on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class mADetailViewController;

@interface mAMasterViewController : UITableViewController

@property (strong, nonatomic) mADetailViewController *detailViewController;

@end
