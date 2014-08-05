//
//  mAConnectViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 8/4/14.
//
//

#import "mAConnectViewController.h"
#import "mANetworkManager.h"


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

#pragma mark IBActions

- (IBAction)cancel:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)createNew:(id)sender
{
    
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.rooms)
        return [self.rooms count];
    else
        return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mAConnectViewController_JoinRoom"];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"mAConnectViewController_JoinRoom"];
    cell.textLabel.text = [[self.rooms objectAtIndex:indexPath.row] name];
    
    return cell;
}

@end
