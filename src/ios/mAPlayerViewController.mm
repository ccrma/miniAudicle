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
#import "mANetworkRoomView.h"
#import "mAAnalytics.h"


@interface mAPlayerViewController ()
{
    int _layoutIndex;
    CGPoint _layoutOffset;
    
    IBOutlet UIButton *_connectButton;
    IBOutlet UIButton *_disconnectButton;
    IBOutlet mANetworkRoomView *_roomView;
}

@property (strong, nonatomic) NSMutableArray *players;
@property (strong, nonatomic) NSMutableArray *passthroughViews;
@property (strong, nonatomic) UIPopoverController *editorPopover;
@property (strong, nonatomic) UIView *fieldView;

@property (strong, nonatomic) mANetworkManager *networkManager;

- (void)setup;
- (void)vmStatus:(NSNotification *)notification;

@end


@implementation mAPlayerViewController

- (void)setup
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 32)];
    titleLabel.text = @"Player";
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [titleLabel sizeToFit];
    //        self.titleButton = [[UIBarButtonItem alloc] initWithTitle:@"Player"
    //                                                            style:UIBarButtonItemStylePlain
    //                                                           target:nil
    //                                                           action:nil];
    self.titleButton = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    //        self.titleButton.enabled = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.players = [NSMutableArray array];
    self.passthroughViews = [NSMutableArray array];
    _layoutIndex = 0;
    _layoutOffset = CGPointMake(0, 0);
    self.networkManager = [mANetworkManager instance];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        [self setup];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _disconnectButton.alpha = 0;
    _roomView.alpha = 0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(vmStatus:)
                                                 name:mAVMMonitorControllerStatusUpdateNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[mAAnalytics instance] playerScreen];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if(self.networkManager.isConnected)
        [self disconnect:nil];
}

- (void)addScript:(mADetailItem *)script
{
    [[mAAnalytics instance] playAddScript:script.uuid];
    
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
        newScript.pos_x = player.view.frame.origin.x;
        newScript.pos_y = player.view.frame.origin.y;
        
        [self.networkManager submitAction:newScript
                             errorHandler:^(NSError *error) {
                                 NSLog(@"error submitting newScript action: %@", error);
                             }];
        
        script.hasLocalEdits = NO;
    }
}

- (void)deleteScriptPlayer:(mAScriptPlayer *)player
{
    [player cleanupForDeletion];
    [self.players removeObject:player];
    [UIView animateWithDuration:G_RATIO-1 animations:^{
        player.view.alpha = 0;
    } completion:^(BOOL finished) {
        [player.view removeFromSuperview];
    }];
}

- (void)deleteAllScriptPlayers
{
    for(mAScriptPlayer *player in self.players)
        [self deleteScriptPlayer:player];
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

- (void)enterSequenceMode:(mAScriptPlayer *)source
{
    for(mAScriptPlayer *player in self.players)
        [player enterSequenceMode:source];
}

- (void)exitSequenceMode
{
    for(mAScriptPlayer *player in self.players)
        [player exitSequenceMode];
}

- (NSArray *)allPlayers
{
    return self.players;
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

- (void)memberJoined:(mANetworkRoomMember *)member
{
    [_roomView addMember:member];
}

- (void)memberLeft:(mANetworkRoomMember *)member
{
    [_roomView removeMember:member];
}

#pragma mark - IBActions

- (IBAction)connect:(id)sender
{
    [self presentViewController:self.connectViewController animated:YES completion:nil];
}

- (IBAction)disconnect:(id)sender
{
    [self.networkManager leaveCurrentRoom];
    [self deleteAllScriptPlayers];
    _connectButton.enabled = YES;
    
    [UIView animateWithDuration:G_RATIO-1 animations:^{
        _disconnectButton.alpha = 0;
        _roomView.alpha = 0;
    }];
}

#pragma mark - mAConnectViewControllerDelegate

- (void)connectViewControllerDidCancel:(mAConnectViewController *)cvc
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)connectViewController:(mAConnectViewController *)cvc selectedRoom:(mANetworkRoom *)room username:(NSString *)username;
{
    [self deleteAllScriptPlayers];
    
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
                               
                               _connectButton.enabled = NO;
                               
                               _roomView.room = room;
                               mANetworkRoomMember *memberSelf = [mANetworkRoomMember new];
                               memberSelf.uuid = [self.networkManager userId];
                               memberSelf.name = username;
                               [_roomView addMember:memberSelf];
                               
                               [UIView animateWithDuration:G_RATIO-1 animations:^{
                                   _roomView.alpha = 1;
                                   _disconnectButton.alpha = 1;
                               }];
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


