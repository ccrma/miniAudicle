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

@property (retain, nonatomic) NSString * text;
@property (nonatomic) t_CKUINT docid;

@end

@interface mADetailViewController : UIViewController <UISplitViewControllerDelegate>
{
    IBOutlet UITextView * textView;
}

@property (strong, nonatomic) mADetailItem * detailItem;
@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;


- (IBAction)newItem;

- (IBAction)addShred;
- (IBAction)replaceShred;
- (IBAction)removeShred;

@end
