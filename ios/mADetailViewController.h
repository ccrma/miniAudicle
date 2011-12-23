//
//  mADetailViewController.h
//  miniAudicle iOS
//
//  Created by Spencer Salazar on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "mATitleEditorController.h"
#import "chuck_def.h"


@class mAMasterViewController;


@interface mADetailItem : NSObject

@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * text;
@property (nonatomic) t_CKUINT docid;

@end

@interface mADetailViewController : UIViewController 
< UISplitViewControllerDelegate, 
mATitleEditorControllerDelegate,
UIPopoverControllerDelegate >
{
    IBOutlet UITextView * _textView;
    IBOutlet UIBarButtonItem * _titleButton;
    IBOutlet UIToolbar * _toolbar;
//    IBOutlet UINavigationItem * _titleButton;
    
    IBOutlet mATitleEditorController * _titleEditor;
}

@property (assign, nonatomic) mAMasterViewController * masterViewController;
@property (strong, nonatomic) mADetailItem * detailItem;
@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;


- (IBAction)addShred;
- (IBAction)replaceShred;
- (IBAction)removeShred;

- (IBAction)editTitle:(id)sender;

@end
