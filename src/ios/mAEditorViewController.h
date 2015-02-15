//
//  mAEditorViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import <UIKit/UIKit.h>

#import "mATitleEditorController.h"
#import "mAKeyboardAccessoryViewController.h"
#import "mAConsoleMonitorController.h"
#import "mASyntaxHighlighter.h"
#import "mADetailViewController.h"

@class mAFileViewController;
@class mAVMMonitorController;
@class mATextView;

@interface mAEditorViewController : UIViewController
< mAKeyboardAccessoryDelegate,
  UIPopoverControllerDelegate,
  mATitleEditorControllerDelegate,
  NSTextStorageDelegate,
  UITextViewDelegate,
  mADetailClient >
{
    IBOutlet mATextView * _textView;
    IBOutlet UIView *_otfToolbar;

    IBOutlet mATitleEditorController * _titleEditor;
}

@property (strong, nonatomic) mADetailItem * detailItem;
@property (strong, nonatomic) IBOutlet mAKeyboardAccessoryViewController *keyboardAccessory;
@property (strong, nonatomic) UIBarButtonItem * titleButton;
@property (nonatomic) BOOL showOTFToolbar;

@property (weak, nonatomic) mAFileViewController *fileViewController;

- (void)saveScript;

- (IBAction)addShred;
- (IBAction)replaceShred;
- (IBAction)removeShred;

@end
