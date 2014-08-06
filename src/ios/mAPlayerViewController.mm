//
//  mAPlayerViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/26/14.
//
//

#import "mAPlayerViewController.h"
#import "mAScriptPlayer.h"
#import "mAScriptPlayerTab.h"
#import "mAVMMonitorController.h"
#import "mAEditorViewController.h"
#import "mANetworkManager.h"
#import "mANetworkAction.h"
#import "mADetailItem.h"
#import "mAConnectViewController.h"
#import "mAActivityViewController.h"


@interface mAPlayerViewController ()
{
    int _layoutIndex;
    CGPoint _layoutOffset;
}

@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) NSMutableArray *passthroughViews;
@property (strong, nonatomic) UIPopoverController *editorPopover;
@property (strong, nonatomic) UIView *fieldView;

@property (strong, nonatomic) mANetworkManager *networkManager;

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
        _layoutIndex = 0;
        _layoutOffset = CGPointMake(0, 0);
        self.networkManager = [mANetworkManager instance];
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
    
    if(self.networkManager.isConnected)
        [self.networkManager leaveCurrentRoom];
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
    player.view.center = CGPointMake(_layoutOffset.x + self.view.bounds.origin.x + self.view.bounds.size.width*0.75 - (_layoutIndex/7)*self.view.bounds.size.width*0.475,
                                     _layoutOffset.y + self.view.bounds.origin.y + self.view.bounds.size.height*0.125*(_layoutIndex%7+1));
    player.playerViewController = self;
    
    [self.fieldView addSubview:player.view];
    [self.players addObject:player];
    [self.passthroughViews addObject:player.view];
    
    _layoutIndex = (_layoutIndex+1)%14;
    if(_layoutIndex == 0) // wrap around
        _layoutOffset = CGPointMake(_layoutOffset.x + 10, _layoutOffset.y + 25);
    
    if(!script.remote && self.networkManager.isConnected)
    {
        player.codeID = [[NSUUID UUID] UUIDString];
        
        // send network action
        mANANewScript *newScript = [mANANewScript new];
        newScript.code_id = player.codeID;
        newScript.code = script.text;
        newScript.name = script.title;
        
        [self.networkManager submitAction:newScript
                             errorHandler:^(NSError *error) {
                                 NSLog(@"error joining room: %@", error);
                             }];
    }
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
    self.editorPopover.backgroundColor = [UIColor clearColor];
    self.editorPopover.delegate = self;
    self.editorPopover.passthroughViews = self.passthroughViews;
    
    UIView *popoverView = [player viewForEditorPopover];
    
    [self.editorPopover presentPopoverFromRect:popoverView.frame
                                        inView:popoverView.superview
                      permittedArrowDirections:UIPopoverArrowDirectionAny
                                      animated:NO];
    
//    self.editor.view.superview.superview.superview.backgroundColor = [UIColor clearColor];
}

- (void)playerTabMoved:(mAScriptPlayerTab *)playerTab
{
    CGRect frame = playerTab.superview.frame;
    if(!CGRectContainsRect(self.fieldView.bounds, frame))
    {
        frame.origin.x -= 10; frame.origin.y -= 10;
        frame.size.width += 20; frame.size.height += 20;
        self.fieldView.bounds = CGRectUnion(self.fieldView.bounds, frame);
//        ((UIScrollView *) self.view).contentSize = self.fieldView.bounds.size;
    }
}

- (mAScriptPlayer *)scriptPlayerForRemoteUUID:(NSString *)uuid
{
    for(mAScriptPlayer *player in self.players)
    {
        if([player.detailItem.remoteUUID isEqualToString:uuid])
            return player;
    }
    
    return nil;
}

#pragma mark IBActions

- (IBAction)connect:(id)sender
{
    [self presentViewController:self.connectViewController animated:YES completion:nil];
}

#pragma mark mAConnectViewControllerDelegate

- (void)connectViewControllerDidCancel:(mAConnectViewController *)cvc
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)connectViewController:(mAConnectViewController *)cvc selectedRoom:(mANetworkRoom *)room username:(NSString *)username;
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        (void) self.activityViewController.view;
        self.activityViewController.textLabel.text = [NSString stringWithFormat:@"Joining %@...", room.name];
        __weak typeof(self) weakSelf = self;
        self.activityViewController.cancelHandler = ^{
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        };
        
        [self presentViewController:self.activityViewController animated:YES completion:^{
            [self.networkManager joinRoom:room.uuid
                                 username:username
                           successHandler:^{
                               [self dismissViewControllerAnimated:YES completion:nil];
                           }
                            updateHandler:^(mANetworkAction *action) {
                                [action execute:self];
                            }
                             errorHandler:^(NSError *error) {
                                 NSLog(@"error joining room: %@", error);
                             }];
            
        }];
    }];
}

@end


