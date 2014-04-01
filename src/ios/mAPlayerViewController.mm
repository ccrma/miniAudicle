//
//  mAPlayerViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import "mAPlayerViewController.h"
#import "mAScriptPlayer.h"
#import "mAVMMonitorController.h"

@interface mAPlayerViewController ()
{
    
}

@property (strong, nonatomic) NSMutableArray *players;

- (void)vmStatus:(NSNotification *)notification;

@end

@implementation mAPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.titleButton = [[UIBarButtonItem alloc] initWithTitle:@"Player"
                                                            style:UIBarButtonItemStylePlain
                                                           target:nil
                                                           action:nil];
        self.titleButton.enabled = NO;
        
        self.players = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vmStatus:)
                                                 name:mAVMMonitorControllerStatusUpdateNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addScript:(mADetailItem *)script
{
    mAScriptPlayer *player = [[mAScriptPlayer alloc] initWithNibName:@"mAScriptPlayer" bundle:nil];
    player.detailItem = script;
    player.view.center = self.view.center;
    [self.view addSubview:player.view];
    [self.players addObject:player];
}

- (void)vmStatus:(NSNotification *)notification
{
    Chuck_VM_Status * status = (Chuck_VM_Status *) [[[notification userInfo] objectForKey:@"status"] pointerValue];
    
    for(mAScriptPlayer *player in self.players)
    {
        [player updateWithStatus:status];
    }
}

@end
