//
//  mASocialLoginViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/26/16.
//
//

#import "mASocialLoginViewController.h"
#import "mALoadingViewController.h"

#import "UIAlert.h"

#import "ChuckPadSocial.h"

@interface mASocialLoginViewController ()
{
    IBOutlet UISegmentedControl *_modeControl;
    
    IBOutlet UIView *_loginView;
    IBOutlet UIView *_createAccountView;
    IBOutlet UIView *_logoutView;
    
    IBOutlet UITextField *_loginUsernameField;
    IBOutlet UITextField *_loginPasswordField;
    
    IBOutlet UITextField *_createUsernameField;
    IBOutlet UITextField *_createEmailField;
    IBOutlet UITextField *_createPasswordField;
    
    mALoadingViewController *_loadingView;
}

- (IBAction)switchMode:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)createAccount:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)cancel:(id)sender;

- (void)_dismiss;
- (void)showLoading:(BOOL)show;

@end

@implementation mASocialLoginViewController

- (id)init
{
    if(self = [super initWithNibName:@"mASocialLoginViewController" bundle:nil])
    {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    // show login view
    _loginView.hidden = NO;
    _createAccountView.hidden = YES;
    _logoutView.hidden = YES;
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(400, 450);
}

- (void)showLoading:(BOOL)show
{
    if(show)
    {
        if(_loadingView == nil)
        {
            _loadingView = [mALoadingViewController new];
            [self.view addSubview:_loadingView.view];
            [_loadingView fit];
        }
    
        [_loadingView show];
    }
    else
    {
        [_loadingView hide];
    }
}

- (void)_dismiss
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

- (void)clearFields
{
    _loginUsernameField.text = @"";
    _loginPasswordField.text = @"";
    _createUsernameField.text = @"";
    _createEmailField.text = @"";
    _createPasswordField.text = @"";
}

#pragma mark - IBActions

- (IBAction)switchMode:(id)sender
{
    NSInteger selectedMode = [(UISegmentedControl *)sender selectedSegmentIndex];
    switch(selectedMode)
    {
        case 0:
            _loginView.hidden = NO;
            _createAccountView.hidden = YES;
            _logoutView.hidden = YES;
            break;
        case 1:
            _loginView.hidden = YES;
            _createAccountView.hidden = NO;
            _logoutView.hidden = YES;
            break;
    }
}

- (IBAction)login:(id)sender
{
    NSString *loginUsername = _loginUsernameField.text;
    NSString *loginPassword = _loginPasswordField.text;
    
    [self showLoading:YES];
    
    ChuckPadSocial *chuckPad = [ChuckPadSocial sharedInstance];
    [chuckPad logIn:loginUsername withPassword:loginPassword
       withCallback:^(BOOL succeeded, NSError *error) {
           
           if(succeeded)
           {
               UIAlertMessage(@"Successfully logged in.", ^{
                   [self _dismiss];
               });
           }
           else
           {
               UIAlertMessage1a(@"Failed to log in.", error.localizedDescription, ^{});
           }
           
           [self showLoading:NO];
       }];
}

- (IBAction)logout:(id)sender
{
    
}

- (IBAction)createAccount:(id)sender
{
    
}

- (IBAction)cancel:(id)sender
{
    [self _dismiss];
}

@end
