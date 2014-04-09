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
#import "mAEditorViewController.h"


@interface mAPlayerViewController ()
{
    
}

@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) NSMutableArray *passthroughViews;
@property (strong, nonatomic) UIPopoverController *editorPopover;

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
        self.passthroughViews = [NSMutableArray array];
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
    player.playerViewController = self;
    
    [self.view addSubview:player.view];
    [self.players addObject:player];
    [self.passthroughViews addObject:player.view];
}

- (void)vmStatus:(NSNotification *)notification
{
    Chuck_VM_Status * status = (Chuck_VM_Status *) [[[notification userInfo] objectForKey:@"status"] pointerValue];
    
    for(mAScriptPlayer *player in self.players)
    {
        [player updateWithStatus:status];
    }
}

- (void)showEditorForScriptPlayer:(mAScriptPlayer *)player
{
    if(self.editorPopover == nil)
    {
        self.editorPopover = [[UIPopoverController alloc] initWithContentViewController:self.editor];
    }
    
    self.editor.detailItem = player.detailItem;
    self.editor.showOTFToolbar = NO;
    self.editorPopover.popoverContentSize = CGSizeMake(480, 600);
    self.editorPopover.delegate = self;
    self.editorPopover.passthroughViews = self.passthroughViews;
    
    UIView *popoverView = [player viewForEditorPopover];
    
    [self.editorPopover presentPopoverFromRect:popoverView.frame
                                        inView:popoverView.superview
                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                      animated:YES];
}

@end


