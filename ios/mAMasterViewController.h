//
//  mAMasterViewController.h
//  miniAudicle iOS
//
//  Created by Spencer Salazar on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class mADetailViewController;

@interface mAMasterViewController : UIViewController
{
    IBOutlet UITableView * _tableView;
    
    NSMutableArray * _scripts;
    int untitledNumber;
}

@property (strong, nonatomic) mADetailViewController *detailViewController;
@property (strong, nonatomic) NSMutableArray * scripts;

- (IBAction)newScript;

- (void)selectScript:(int)script;
- (int)selectedScript;
- (void)scriptDetailChanged;

@end
