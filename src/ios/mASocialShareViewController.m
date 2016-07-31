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

@interface mASocialShareViewController ()
{
    mALoadingViewController *_loadingView;
    
    IBOutlet UITextField *_nameTextField;
    IBOutlet UIButton *_nameEditButton;
    IBOutlet UITextView *_descriptionTextView;
    IBOutlet UIImageView *_compileStatusIcon;
    IBOutlet UILabel *_compileMessage;
    
    IBOutlet UIButton *_uploadButton;
    
    BOOL _nameEditorIsShowing;

    BOOL _scriptCompiles;
    NSString *_compileError;
}

- (IBAction)editName:(id)sender;
- (IBAction)upload:(id)sender;
- (IBAction)cancel:(id)sender;

- (void)_dismiss;
- (void)_showLoading:(BOOL)show;
- (void)_showLoading:(BOOL)show status:(NSString *)status;
- (void)_showCompiles:(BOOL)compiles error:(NSString *)compileError;
- (void)_toggleNameEditor;
- (void)_showNameEditor:(BOOL)show;

@end

@implementation mASocialShareViewController

- (void)setScript:(mADetailItem *)script
{
    _script = script;
    
    _nameTextField.text = script.title;
    
    _descriptionTextView.text = @"";
    
    // check script
    NSString *compileError = nil;
    _scriptCompiles = [[mAChucKController chuckController] chuckCodeCompiles:script error:&compileError];
    _compileError = compileError;
    [self _showCompiles:_scriptCompiles error:_compileError];
}

- (id)init
{
    if(self = [super initWithNibName:@"mASocialShareViewController" bundle:nil])
    {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        _scriptCompiles = NO;
        [self _showCompiles:NO error:@""];
        [self _showNameEditor:NO];
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

- (void)_showLoading:(BOOL)show status:(NSString *)status
{
    [self _showLoading:show];
    _loadingView.status = status;
}

- (void)_dismiss
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

- (void)_showCompiles:(BOOL)compiles error:(NSString *)compileError
{
    if(compiles)
    {
        [_compileStatusIcon setImage:[[UIImage imageNamed:@"Checked Filled-100"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_compileStatusIcon setTintColor:[UIColor colorWithRed:48.0f/255.0f green:142.0f/255.0f blue:24.0f/255.0f alpha:1.0]];
        [_compileMessage setText:@""];
    }
    else
    {
        [_compileStatusIcon setImage:[[UIImage imageNamed:@"Cancel Filled-100"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        [_compileStatusIcon setTintColor:[UIColor colorWithRed:224.0f/255.0f green:24.0f/255.0f blue:24.0f/255.0f alpha:1.0]];
        [_compileMessage setText:compileError];
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
        _nameTextField.borderStyle = UITextBorderStyleNone;
        [_nameEditButton setImage:[UIImage imageNamed:@"Edit-100.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - IBActions

- (IBAction)editName:(id)sender
{
    [self _toggleNameEditor];
}

- (IBAction)upload:(id)sender
{
    NSAssert(self.script.type == DETAILITEM_CHUCK_SCRIPT, @"upload on item that is not a script");
    
    if(!_scriptCompiles)
    {
        if(_compileError)
            UIAlertMessage1a(@"Please fix the compilation error before sharing.", _compileError, ^{});
        else
            UIAlertMessage(@"Please fix the compilation error before sharing.", ^{});
        
        return;
    }
    
    NSString *name = _nameTextField.text;
    NSString *filename = [self.script.path lastPathComponent];
    NSData *fileData = [self.script.text dataUsingEncoding:NSUTF8StringEncoding];
    NSString *description = [_descriptionTextView text];
    
    if([name length] == 0)
    {
        UIAlertMessage(@"Please enter a name for your script before sharing.", ^{});
        return;
    }
    
    if(fileData == nil || [fileData length] == 0)
    {
        // uhh...
        UIAlertMessage(@"Unable to load script data for uploading.", ^{});
        return;
    }
    
    [self _showLoading:YES status:@"Uploading patch"];
       
    ChuckPadSocial *chuckPad = [ChuckPadSocial sharedInstance];
    [chuckPad uploadPatch:name
              description:description parent:-1
                 filename:filename fileData:fileData
                 callback:^(BOOL succeeded, Patch *patch, NSError *error) {
                     if(succeeded)
                     {
                         UIAlertMessage(@"Upload succeeded", ^{});
                         self.script.patch = patch;
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
                         UIAlertMessage1a(@"Failed to upload patch", error.localizedDescription, ^{});
                     }
                     
                     [self _showLoading:NO];
                 }];
}

- (IBAction)cancel:(id)sender
{
    [self _dismiss];
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

@end
