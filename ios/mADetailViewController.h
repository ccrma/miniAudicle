//
//  mADetailViewController.h
//  miniAudicle iOS
//
//  Created by Spencer Salazar on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "chuck_def.h"


@interface mADetailItem : NSObject

@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * text;
@property (nonatomic) t_CKUINT docid;

@end

@interface mADetailViewController : UIViewController <UISplitViewControllerDelegate>
{
    IBOutlet UITextView * _textView;
    IBOutlet UINavigationItem * _titleButton;
}

@property (strong, nonatomic) mADetailItem * detailItem;
@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;


- (IBAction)addShred;
- (IBAction)replaceShred;
- (IBAction)removeShred;

@end
