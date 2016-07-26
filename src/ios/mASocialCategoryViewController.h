//
//  mASocialCategoryTableViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 7/25/16.
//
//

#import <UIKit/UIKit.h>

@class mADetailViewController;
@class mASocialFileViewController;

@interface mASocialCategoryViewController : UITableViewController

@property (strong, nonatomic) mADetailViewController *detailViewController;

- (mASocialFileViewController *)defaultCategoryViewController;

@end
