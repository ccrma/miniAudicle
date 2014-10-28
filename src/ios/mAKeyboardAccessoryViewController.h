//
//  mAKeyboardAccessoryViewViewController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/22/14.
//
//

#import <UIKit/UIKit.h>

@class mAKeyboardButton;

@protocol mAKeyboardAccessoryDelegate

- (void)keyPressed:(NSString *)chars selectionOffset:(NSInteger)offset;

@end

@interface mAKeyboardAccessoryViewController : UIViewController
{
    IBOutlet mAKeyboardButton *_chuckButton;
    IBOutlet mAKeyboardButton *_dacButton;
    IBOutlet mAKeyboardButton *_doublequoteButton;
    IBOutlet mAKeyboardButton *_parenButton;
    IBOutlet mAKeyboardButton *_bracketButton;
    IBOutlet mAKeyboardButton *_braceButton;
}

@property (weak, nonatomic) id<mAKeyboardAccessoryDelegate> delegate;

- (IBAction)keyPressed:(id)sender;

@end
