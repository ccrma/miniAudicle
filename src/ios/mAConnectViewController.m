//
//  mAConnectViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 8/4/14.
//
//

#import "mAConnectViewController.h"
#import "mANetworkManager.h"
#import "UIAlert.h"


NSString * const mAConnectUsernameKey = @"mAConnectUsernameKey";


@interface mAConnectViewController ()
{
    IBOutlet UITextField *_usernameTextField;
    IBOutlet UIView *_loadingView;
    IBOutlet UIActivityIndicatorView *_activityIndicator;
    IBOutlet UILabel *_connectionErrorLabel;
    IBOutlet UITableView *_roomTable;
}

@property (strong, nonatomic) NSArray *rooms;

@end

@implementation mAConnectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    _usernameTextField.text = [[NSUserDefaults standardUserDefaults] stringForKey:mAConnectUsernameKey];
    
    [_connectionErrorLabel removeFromSuperview];
    self.rooms = nil;
    [_roomTable reloadData];

    _loadingView.alpha = 1.0;
    [self.view addSubview:_loadingView];
    [self.view bringSubviewToFront:_loadingView];
    [_activityIndicator startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[mANetworkManager instance] listRooms:^(NSArray *rooms) {
        
        [_activityIndicator stopAnimating];
        [UIView animateWithDuration:0.5 animations:^{
            _loadingView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [_loadingView removeFromSuperview];
        }];
        
        self.rooms = rooms;
        [_roomTable reloadData];
        
    } errorHandler:^(NSError *error) {
        NSLog(@"error listing rooms: %@", error);
        [_activityIndicator stopAnimating];
        [_loadingView addSubview:_connectionErrorLabel];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
}

// see http://stackoverflow.com/questions/3124828/resignfirstresponder-not-hiding-keyboard-on-textfieldshouldreturn
- (BOOL)disablesAutomaticKeyboardDismissal { return NO; }

#pragma mark IBActions

- (IBAction)cancel:(id)sender
{
//    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    [self.delegate connectViewControllerDidCancel:self];
}

- (IBAction)createNew:(id)sender
{
    
}

#pragma mark UITableViewDataSource / UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.rooms)
        return [self.rooms count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    mANetworkRoom *room = [self.rooms objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mAConnectViewController_JoinRoom"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:@"mAConnectViewController_JoinRoom"];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.text = room.name;
    cell.detailTextLabel.text = room.info;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_usernameTextField.text length])
    {
        [[NSUserDefaults standardUserDefaults] setObject:_usernameTextField.text
                                                  forKey:mAConnectUsernameKey];
        
        [self.delegate connectViewController:self
                                selectedRoom:[self.rooms objectAtIndex:indexPath.row]
                                    username:_usernameTextField.text];
    }
    else
    {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please enter a username."
//                                                            message:@""
//                                                           delegate:nil
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles:nil];
//        
//        [alertView show];
        
        UIAlertMessage(@"Please enter a username.", ^{
            [_usernameTextField becomeFirstResponder];
        });
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


@end


