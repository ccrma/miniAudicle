//
//  mASocialShareViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/27/16.
//
//

#import "mASocialShareViewController.h"
#import "mADetailItem.h"
#import "mADetailItem+Social.h"
#import "mALoadingViewController.h"
#import "mAChuckController.h"
#import "mAAnalytics.h"

#import "UIAlert.h"

#import "Patch.h"
#import "ChuckPadSocial.h"

typedef enum ShareMode
{
    mAShareModeUpload,
    mAShareModeUpdate
} ShareMode;

@interface mASocialShareViewController ()
{
    IBOutlet UILabel *_headingLabel;
    IBOutlet UILabel *_callToActionLabel;
    IBOutlet UITextField *_nameTextField;
    IBOutlet UIButton *_nameEditButton;
    IBOutlet UILabel *_revisionLabel;
    IBOutlet UITextView *_descriptionTextView;
    IBOutlet UIButton *_descriptionEditButton;
    IBOutlet UIImageView *_compileStatusIcon;
    IBOutlet UILabel *_compileMessage;
    
    IBOutlet UIButton *_deleteButton;
    IBOutlet UIButton *_uploadButton;
    
    mALoadingViewController *_loadingView;
    
    ShareMode _shareMode;
    
    BOOL _nameEditorIsShowing;
    BOOL _descriptionEditorIsShowing;

    BOOL _scriptCompiles;
    NSString *_compileError;
}

- (IBAction)editName:(id)sender;
- (IBAction)editDescription:(id)sender;
- (IBAction)upload:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)delete:(id)sender;

- (void)_setUploadMode;
- (void)_setUpdateMode;

- (void)_dismiss;
- (void)_showLoading:(BOOL)show;
- (void)_showLoading:(BOOL)show status:(NSString *)status;
- (void)_showCompiles:(BOOL)compiles error:(NSString *)compileError;
- (void)_toggleNameEditor;
- (void)_showNameEditor:(BOOL)show;
- (void)_toggleDescriptionEditor;
- (void)_showDescriptionEditor:(BOOL)show;

@end

@implementation mASocialShareViewController

- (void)setScript:(mADetailItem *)script
{
    _script = script;
    
    _nameTextField.text = script.title;
    _descriptionTextView.text = @"";
    _revisionLabel.text = [NSString stringWithFormat:@"Revision %i", 1];
    
    // check script
    NSString *compileError = nil;
    _scriptCompiles = [[mAChucKController chuckController] chuckCodeCompiles:script error:&compileError];
    _compileError = compileError;
    [self _showCompiles:_scriptCompiles error:_compileError];
    
    ChuckPadSocial *chuckPad = [ChuckPadSocial sharedInstance];
    
    if(script.patch && [chuckPad getLoggedInUserId] == script.patch.creatorId)
    {
        [self _setUpdateMode];
        _nameTextField.text = script.patch.name;
        _descriptionTextView.text = script.patch.patchDescription;
        _revisionLabel.text = [NSString stringWithFormat:@"Revision %li", script.patch.revision+1];
    }
    else
    {
        [self _setUploadMode];
    }
}

- (id)init
{
    if(self = [super initWithNibName:@"mASocialShareViewController" bundle:nil])
    {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        [self _setUploadMode];
        _scriptCompiles = NO;
        [self _showCompiles:NO error:@""];
        [self _showNameEditor:NO];
        
        _nameEditorIsShowing = NO;
        _descriptionEditorIsShowing = NO;
    }
    
    return self;
}

- (void)viewDidLoad
{
    // force reload
    self.script = self.script;
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(375, 425);
}

- (void)_showLoading:(BOOL)show
{
    if(show)
    {
        if(_loadingView == nil)
        {
            _loadingView = [mALoadingViewController new];
            _loadingView.loadingViewStyle = mALoadingViewStyleOpaque;
            [self.view addSubview:_loadingView.view];
            [_loadingView fit];
        }
        
        [_loadingView show];
    }
    else
    {
        [_loadingView hide:^{
            _loadingView = nil;
        }];
    }
}

- (void)_setUploadMode
{
    _shareMode = mAShareModeUpload;
    _headingLabel.text = @"Share Script";
    _callToActionLabel.text = @"Upload your script on Chuckpad Social to share it with the world.";
    _descriptionTextView.backgroundColor = [UIColor whiteColor];
    _descriptionEditButton.hidden = YES;
    _deleteButton.hidden = YES;
    [_uploadButton setTitle:@"Upload" forState:UIControlStateNormal];
}

- (void)_setUpdateMode
{
    _shareMode = mAShareModeUpdate;
    _headingLabel.text = @"Update Shared Script";
    _callToActionLabel.text = @"Your script is now on Chuckpad Social. You can update the shared verison with any changes you've made.";
    _descriptionTextView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    _descriptionEditButton.hidden = NO;
    _deleteButton.hidden = NO;
    [_uploadButton setTitle:@"Update" forState:UIControlStateNormal];
}

- (void)_showLoading:(BOOL)show status:(NSString *)status
{
    [self _showLoading:show];
    _loadingView.status = status;
}

- (void)_dismiss
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_showCompiles:(BOOL)compiles error:(NSString *)compileError
{
    if(compiles)
    {
        [_compileStatusIcon setImage:[[UIImage imageNamed:@"Checked Filled-100"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_compileStatusIcon setTintColor:[UIColor colorWithRed:48.0f/255.0f green:142.0f/255.0f blue:24.0f/255.0f alpha:1.0]];
        [_compileMessage setText:@""];
//        [_uploadButton setTitleColor:nil forState:UIControlStateNormal];
    }
    else
    {
        [_compileStatusIcon setImage:[[UIImage imageNamed:@"Cancel Filled-100"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_compileStatusIcon setTintColor:[UIColor colorWithRed:224.0f/255.0f green:24.0f/255.0f blue:24.0f/255.0f alpha:1.0]];
        [_compileMessage setText:compileError];
//        [_uploadButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (void)_toggleNameEditor
{
    [self _showNameEditor:!_nameEditorIsShowing];
}

- (void)_showNameEditor:(BOOL)show
{
    if(show)
    {
        _nameEditorIsShowing = YES;
        
        _nameTextField.enabled = YES;
        _nameTextField.backgroundColor = [UIColor whiteColor];
        [_nameTextField becomeFirstResponder];
        [_nameEditButton setImage:[UIImage imageNamed:@"Edit Filled-100.png"] forState:UIControlStateNormal];
    }
    else
    {
        _nameEditorIsShowing = NO;
        
        _nameTextField.enabled = NO;
        _nameTextField.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [_nameEditButton setImage:[UIImage imageNamed:@"Edit-100.png"] forState:UIControlStateNormal];
    }
}

- (void)_toggleDescriptionEditor
{
    if(_shareMode == mAShareModeUpdate)
        [self _showDescriptionEditor:!_descriptionEditorIsShowing];
}

- (void)_showDescriptionEditor:(BOOL)show
{
    if(show)
    {
        _descriptionEditorIsShowing = YES;
        
        _descriptionTextView.editable = YES;
        _descriptionTextView.backgroundColor = [UIColor whiteColor];
        [_descriptionTextView becomeFirstResponder];
        [_descriptionEditButton setImage:[UIImage imageNamed:@"Edit Filled-100.png"] forState:UIControlStateNormal];
    }
    else
    {
        _descriptionEditorIsShowing = NO;
        
        _descriptionTextView.editable = NO;
        _descriptionTextView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        [_descriptionEditButton setImage:[UIImage imageNamed:@"Edit-100.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - IBActions

- (IBAction)editName:(id)sender
{
    [self _toggleNameEditor];
}

- (IBAction)editDescription:(id)sender
{
    [self _toggleDescriptionEditor];
}

- (IBAction)upload:(id)sender
{
    NSAssert(self.script.type == DETAILITEM_CHUCK_SCRIPT, @"upload on item that is not a script");
    
    if(!_scriptCompiles)
    {
        if(_compileError)
            UIAlertMessage1a(@"Please fix any compilation errors before sharing.", _compileError, nil);
        else
            UIAlertMessage(@"Please fix any compilation errors before sharing.", nil);
        
        return;
    }
    
    NSString *name = _nameTextField.text;
    NSData *fileData = [self.script.text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *description = [_descriptionTextView text];
    
    if([name length] == 0)
    {
        UIAlertMessage(@"Please enter a name for your script before sharing.", nil);
        return;
    }
    
    if(fileData == nil || [fileData length] == 0)
    {
        // uhh...
        UIAlertMessage(@"Unable to load script data for uploading.", nil);
        return;
    }
    
    ChuckPadSocial *chuckPad = [ChuckPadSocial sharedInstance];
    
    if(_shareMode == mAShareModeUpload)
    {
        [self _showLoading:YES status:@"Uploading patch"];
        
        [chuckPad uploadPatch:name
                  description:description
                       parent:nil
                    patchData:fileData
                extraMetaData:nil
                     callback:^(BOOL succeeded, Patch *patch, NSError *error) {
                         if(succeeded)
                         {
                             UIAlertMessage(@"Upload succeeded", nil);
                             self.script.patch = patch;
                             self.script.socialGUID = patch.guid;
                             [self _setUpdateMode];
                             [self _dismiss];
                         }
                         else
                         {
                             NSString *msg = @"";
                             if(error)
                             {
                                 mAAnalyticsLogError(error);
                                 msg = error.localizedDescription;
                             }
                             UIAlertMessage1a(@"Failed to upload patch", msg, nil);
                         }
                         
                         [self _showLoading:NO];
                     }];
    }
    else if(_shareMode == mAShareModeUpdate)
    {
        [self _showLoading:YES status:@"Updating patch"];
        
        [chuckPad updatePatch:self.script.patch
                       hidden:@NO
                         name:name
                  description:description
                    patchData:fileData
                extraMetaData:nil
                     callback:^(BOOL succeeded, Patch *patch, NSError *error) {
                         if(succeeded)
                         {
                             self.script.patch = patch;
                             self.script.socialGUID = patch.guid;
                             UIAlertMessage(@"Update succeeded", nil);
                             [self _dismiss];
                         }
                         else
                         {
                             NSString *msg = @"";
                             if(error)
                             {
                                 mAAnalyticsLogError(error);
                                 msg = error.localizedDescription;
                             }
                             UIAlertMessage1a(@"Failed to update patch", msg, nil);
                         }
                         
                         [self _showLoading:NO];
                     }];
    }
}

- (IBAction)cancel:(id)sender
{
    [self _dismiss];
}

- (IBAction)delete:(id)sender
{
    NSString *title = [NSString stringWithFormat:@"Are you sure you want to delete '%@' from Chuckpad Social?", self.script.patch.name];
    NSString *msg = @"You will not be able to revert this action. Local copies on this device or other devices will not be deleted.";
    
    UIAlertMessage2a(title, msg,
                     @"Cancel", nil,
                     @"Delete", ^{
                         [self _showLoading:YES];
                         
                         ChuckPadSocial *chuckPad = [ChuckPadSocial sharedInstance];
                         
                         [chuckPad deletePatch:self.script.patch
                                      callback:^(BOOL succeeded, NSError *error) {
                                          if(succeeded)
                                          {
                                              NSString *msg = [NSString stringWithFormat:@"'%@' was deleted from Chuckpad Social.", self.script.patch.name];
                                              UIAlertMessage(msg, nil);
                                              self.script.patch = nil;
                                              [self _setUploadMode];
                                          }
                                          else
                                          {
                                              NSString *msg = @"";
                                              if(error)
                                              {
                                                  mAAnalyticsLogError(error);
                                                  msg = error.localizedDescription;
                                              }
                                              UIAlertMessage1a(@"Failed to delete patch.", msg, nil);
                                          }
                                          
                                          [self _showLoading:NO];
                                      }];
                    });
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self _showNameEditor:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(_shareMode == mAShareModeUpdate)
        [self _showDescriptionEditor:NO];
}

@end
