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

- (void)keyPressed:(NSString *)chars;

@end

@interface mAKeyboardAccessoryViewController : UIViewController
{
    IBOutlet mAKeyboardButton *_chuckButton;
    IBOutlet mAKeyboardButton *_dacButton;
}

@property (weak, nonatomic) id<mAKeyboardAccessoryDelegate> delegate;

- (IBAction)keyPressed:(id)sender;

@end
