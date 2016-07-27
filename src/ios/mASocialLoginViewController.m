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
    
    IBOutlet UILabel *_loggedInUsernameField;
    
    mALoadingViewController *_loadingView;
    
    BOOL _loggedInMode;
}

- (IBAction)switchMode:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)createAccount:(id)sender;
- (IBAction)logout:(id)sender;
- (IBAction)cancel:(id)sender;

- (void)_configureTabs;
- (void)_dismiss;
- (void)_showLoading:(BOOL)show;
- (void)_showLoading:(BOOL)show status:(NSString *)status;

@end

@implementation mASocialLoginViewController

- (id)init
{
    if(self = [super initWithNibName:@"mASocialLoginViewController" bundle:nil])
    {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        _loggedInMode = NO;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _loggedInUsernameField.text = @"";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self _configureTabs];
    
    if(!_createAccountView.hidden)
        [_createUsernameField becomeFirstResponder];
    else if(!_loginView.hidden)
        [_loginUsernameField becomeFirstResponder];
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(375, 400);
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

- (void)_configureTabs
{
    ChuckPadSocial *chuckPad = [ChuckPadSocial sharedInstance];
    if([chuckPad isLoggedIn])
    {
        _loggedInMode = YES;
        [_modeControl removeAllSegments];
        [_modeControl insertSegmentWithTitle:@"Logged In" atIndex:0 animated:YES];
        
        _loggedInUsernameField.text = [chuckPad getLoggedInUserName];
        
        _modeControl.selectedSegmentIndex = 0;
        
        _loginView.hidden = YES;
        _createAccountView.hidden = YES;
        _logoutView.hidden = NO;
    }
    else
    {
        _loggedInMode = NO;
        [_modeControl removeAllSegments];
        [_modeControl insertSegmentWithTitle:@"Create Account" atIndex:0 animated:YES];
        [_modeControl insertSegmentWithTitle:@"Login" atIndex:1 animated:YES];
        
        _modeControl.selectedSegmentIndex = 0;
        
        _loginView.hidden = YES;
        _createAccountView.hidden = NO;
        _logoutView.hidden = YES;
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
    
    if(_loggedInMode)
    {
        switch(selectedMode)
        {
            case 0:
                _loginView.hidden = YES;
                _createAccountView.hidden = YES;
                _logoutView.hidden = NO;
                break;
        }
    }
    else
    {
        switch(selectedMode)
        {
            case 0:
                _loginView.hidden = YES;
                _createAccountView.hidden = NO;
                _logoutView.hidden = YES;
                [_createUsernameField becomeFirstResponder];
                break;
                
            case 1:
                _loginView.hidden = NO;
                _createAccountView.hidden = YES;
                _logoutView.hidden = YES;
                [_loginUsernameField becomeFirstResponder];
                break;
        }
    }
}

- (IBAction)login:(id)sender
{
    NSString *username = _loginUsernameField.text;
    NSString *password = _loginPasswordField.text;
    
    [self _showLoading:YES status:@"Logging in"];
    
    ChuckPadSocial *chuckPad = [ChuckPadSocial sharedInstance];
    [chuckPad logIn:username password:password
       callback:^(BOOL succeeded, NSError *error) {
           [self _showLoading:NO];

           if(succeeded)
           {
               [self _configureTabs];
               UIAlertMessage(@"Successfully logged in.", ^{
                   [self _dismiss];
               });
           }
           else
           {
               UIAlertMessage1a(@"Failed to log in.", error.localizedDescription, ^{});
           }
       }];
}

- (IBAction)logout:(id)sender
{
    UIAlertMessage2(@"Are you sure you want to logout?",
                    @"Cancel", ^{ },
                    @"Logout", ^{
                        ChuckPadSocial *chuckPad = [ChuckPadSocial sharedInstance];
                        [chuckPad logOut];
                        [self _configureTabs];
                    });
}

- (IBAction)createAccount:(id)sender
{
    NSString *username = _createUsernameField.text;
    NSString *email = _createEmailField.text;
    NSString *password = _createPasswordField.text;
    
    [self _showLoading:YES status:@"Creating account"];
    
    ChuckPadSocial *chuckPad = [ChuckPadSocial sharedInstance];
    [chuckPad createUser:username email:email password:password
                callback:^(BOOL succeeded, NSError *error) {
                    [self _showLoading:NO];
                    
                    if(succeeded)
                    {
                        [self _configureTabs];
                        UIAlertMessage(@"Successfully created new account.", ^{
                            [self _dismiss];
                        });
                    }
                    else
                    {
                        UIAlertMessage1a(@"Failed to create account.", error.localizedDescription, ^{});
                    }
                }];
}

- (IBAction)cancel:(id)sender
{
    [self _dismiss];
}

@end
