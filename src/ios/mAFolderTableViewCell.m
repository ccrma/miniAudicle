//
//  mAFolderTableViewCell.m
//  miniAudicle
//
//  Created by Spencer Salazar on 5/14/16.
//
//

#import "mAFolderTableViewCell.h"
#import "mADetailItem.h"
#import "mADocumentManager.h"
#import "UIAlert.h"
#import "mAAnalytics.h"

@interface mAFolderTableViewCell ()

@property (strong, nonatomic) IBOutlet UITextField *textField;

@end

@implementation mAFolderTableViewCell

- (void)setItem:(mADetailItem *)item
{
    // remove observer from old item
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:mADetailItemTitleChangedNotification
                                                  object:_item];
    
    _item = item;
    self.textField.text = item.title;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(detailItemTitleChanged:)
                                                 name:mADetailItemTitleChangedNotification
                                               object:item];
}

- (void)awakeFromNib
{
    self.textField.text = self.item.title;
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                                      action:@selector(editFolderName:)];
    [self addGestureRecognizer:longPressRecognizer];
}

- (IBAction)editFolderName:(id)sender
{
    [[mAAnalytics instance] editFolderName];
    self.textField.enabled = YES;
    [self.textField becomeFirstResponder];
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
}

- (void)detailItemTitleChanged:(NSNotification *)n
{
    self.textField.text = self.item.title;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSError *error = nil;
    
    if(![self.textField.text isEqualToString:self.item.title])
    {
        [[mADocumentManager manager] renameItem:self.item to:self.textField.text error:&error];
    }
    
    if(error != nil)
    {
        UIAlertMessage2a(@"The file could not be renamed.",
                         error.localizedFailureReason,
                         @"Cancel", ^{
                             self.textField.text = self.item.title;
                             self.textField.enabled = NO;
                             self.textField.borderStyle = UITextBorderStyleNone;
                             [self.textField resignFirstResponder];
                         },
                         @"Choose Another Name", ^{
                             [self editFolderName:nil];
                         });
    }
    else
    {
        self.textField.enabled = NO;
        self.textField.borderStyle = UITextBorderStyleNone;
        [self.textField resignFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    
    return YES;
}

@end
