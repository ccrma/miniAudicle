//
//  mAFolderTableViewCell.h
//  miniAudicle
//
//  Created by Spencer Salazar on 5/14/16.
//
//

#import <UIKit/UIKit.h>

@class mADetailItem;

@interface mAFolderTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (strong, nonatomic) mADetailItem *item;

- (void)beginEditingFolderTitle;

@end
