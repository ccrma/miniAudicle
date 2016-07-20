/*----------------------------------------------------------------------------
 miniAudicle iOS
 iOS GUI to chuck audio programming environment
 
 Copyright (c) 2005-2012 Spencer Salazar.  All rights reserved.
 http://chuck.cs.princeton.edu/
 http://soundlab.cs.princeton.edu/
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 U.S.A.
 -----------------------------------------------------------------------------*/

#import "mADetailViewController.h"

#import "mAChucKController.h"
#import "mATitleEditorController.h"
#import "mAEditorViewController.h"
#import "mAPlayerViewController.h"
#import "mAVMMonitorController.h"
#import "mAConsoleMonitorController.h"
#import "mAPreferencesViewController.h"
#import "mAKeyboardAccessoryViewController.h"
#import "NSString+NSString_Lines.h"
#import "mATextView.h"
#import "mADetailItem.h"
#import "mADocumentManager.h"
#import "mAAnalytics.h"


/*
 Most likely single-characters in the chuck examples directory and subdirs:
 / 7191
 . 5033
 > 4894
 ; 4367
 - 4222
 = 3721
 ( 3112
 ) 3111
 , 2106
 < 1762
 : 1683
 " 1434
 { 667
 } 666
 ] 626
 [ 626
 + 603
 _ 341
 * 282
 ' 194
 @ 161
 ! 120
 % 95
 ~ 61
 | 61
 \ 46
 # 41
 $ 40
 & 30
 ^ 15
 ? 11
*/


@interface mADetailViewController ()
{
    IBOutlet UIBarButtonItem *_consoleMonitorButton;
    IBOutlet UIBarButtonItem *_vmMonitorButton;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@property (strong, nonatomic) UIToolbar * toolbar;

@property (strong, nonatomic) UIPopoverController * vmMonitorPopover;
@property (strong, nonatomic) mAVMMonitorController * vmMonitor;

@property (strong, nonatomic) UIPopoverController * consoleMonitorPopover;
@property (strong, nonatomic) mAConsoleMonitorController * consoleMonitor;

@property (strong, nonatomic) UIPopoverController * settingsPopover;
@property (strong, nonatomic) IBOutlet mAPreferencesViewController * preferences;

- (void)changeMode:(id)sender;
- (void)_closeOpenPopovers;

@end

@implementation mADetailViewController

@synthesize toolbar = _toolbar;

@synthesize vmMonitor = _vmMonitor;
@synthesize consoleMonitor = _consoleMonitor;

#pragma mark - Managing the detail item

- (void)showMasterPopover
{
    self.splitViewController.preferredDisplayMode = UISplitViewControllerDisplayModePrimaryOverlay;
}

- (void)dismissMasterPopover
{
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSMutableArray * items = [NSMutableArray arrayWithArray:self.toolbar.items];
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"〈 EDIT", @"PLAY 〉"]];
    [segmentedControl addTarget:self action:@selector(changeMode:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = 0;
    [items insertObject:[[UIBarButtonItem alloc] initWithCustomView:segmentedControl]
                atIndex:[items count]];
    [self.toolbar setItems:items animated:NO];
    
    [self editMode:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
        self.interactionMode = MA_IM_NONE;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder])
    {
        self.title = NSLocalizedString(@"Detail", @"Detail");
        self.interactionMode = MA_IM_NONE;
    }
    return self;
}

- (void)setClientViewController:(UIViewController *)viewController
{
    if(self.clientViewController != viewController)
    {
        _clientViewController = viewController;
        
        for(UIView *subview in [_clientView subviews])
            [subview removeFromSuperview];
        
        viewController.view.frame = _clientView.bounds;
        [_clientView addSubview:viewController.view];
        
        // update title button
        // i.e. button with tag == -1
        NSMutableArray * items = [NSMutableArray arrayWithArray:self.toolbar.items];
        int i;
        for(i = 0; i < [items count]; i++)
        {
            if([[items objectAtIndex:i] tag] == -1)
                break;
        }
        
        [items insertObject:[(id<mADetailClient>)viewController titleButton]
                    atIndex:i];
        [(id<mADetailClient>)viewController titleButton].tag = -1;
        [items removeObjectAtIndex:i+1];
        
        [self.toolbar setItems:items animated:YES];
    }
}

- (void)showDetailItem:(mADetailItem *)detailItem
{
    if(self.interactionMode == MA_IM_EDIT)
    {
        [[mADocumentManager manager] addRecentFile:detailItem];
        self.editor.detailItem = detailItem;
        [self dismissMasterPopover];
    }
    else
    {
        [self.player addScript:detailItem];
    }
}

- (void)editItem:(mADetailItem *)item
{
    [self editMode:self];
    [self showDetailItem:item];
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController 
     willHideViewController:(UIViewController *)viewController 
          withBarButtonItem:(UIBarButtonItem *)barButtonItem 
       forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Scripts", @"Scripts");
    
//    [self.titleButton setLeftBarButtonItem:barButtonItem animated:YES];
    NSMutableArray * items = [NSMutableArray arrayWithArray:self.toolbar.items];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:items animated:YES];
    
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController 
     willShowViewController:(UIViewController *)viewController 
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
//    [self.titleButton setLeftBarButtonItem:nil animated:YES];    
    NSMutableArray * items = [NSMutableArray arrayWithArray:self.toolbar.items];
    [items removeObject:barButtonItem];
    [self.toolbar setItems:items animated:YES];
    
    self.masterPopoverController = nil;
}


- (IBAction)showVMMonitor:(id)sender
{
    [[mAAnalytics instance] shredsButton];

    if(self.vmMonitorPopover == nil)
    {
        self.vmMonitorPopover = [[UIPopoverController alloc] initWithContentViewController:self.vmMonitor];
    }
    
    if(self.vmMonitorPopover.isPopoverVisible)
    {
        [self.vmMonitorPopover dismissPopoverAnimated:YES];
    }
    else
    {
        [self _closeOpenPopovers];
        
        self.vmMonitorPopover.delegate = self;
        
        [self.vmMonitorPopover presentPopoverFromBarButtonItem:sender
                                      permittedArrowDirections:UIPopoverArrowDirectionUp
                                                      animated:YES];
    }
}

- (IBAction)showConsoleMonitor:(id)sender
{
    [[mAAnalytics instance] consoleButton];
    
    // clear "new data" indicator
    _consoleMonitorButton.title = @"Console";
    
    if(self.consoleMonitorPopover == nil)
    {
        self.consoleMonitorPopover = [[UIPopoverController alloc] initWithContentViewController:self.consoleMonitor];
    }
    
    if(self.consoleMonitorPopover.isPopoverVisible)
    {
        [self.consoleMonitorPopover dismissPopoverAnimated:YES];
    }
    else
    {
        [self _closeOpenPopovers];
        
        self.consoleMonitorPopover.delegate = self;
        
        [self.consoleMonitorPopover presentPopoverFromBarButtonItem:sender
                                           permittedArrowDirections:UIPopoverArrowDirectionUp
                                                           animated:YES];
    }
}

- (IBAction)showSettings:(id)sender
{
    [[mAAnalytics instance] settingsButton];
    
    if(self.settingsPopover == nil)
    {
        self.settingsPopover = [[UIPopoverController alloc] initWithContentViewController:self.preferences];
    }
    
    if(self.settingsPopover.isPopoverVisible)
    {
        [self.settingsPopover dismissPopoverAnimated:YES];
    }
    else
    {
        [self _closeOpenPopovers];
        
        self.settingsPopover.delegate = self;
        self.preferences.popoverController = self.settingsPopover;
        
        [self.settingsPopover presentPopoverFromBarButtonItem:sender
                                     permittedArrowDirections:UIPopoverArrowDirectionUp
                                                     animated:YES];
    }
}

- (void)_closeOpenPopovers
{
    [self.masterPopoverController dismissPopoverAnimated:NO];
    [self.vmMonitorPopover dismissPopoverAnimated:NO];
    [self.consoleMonitorPopover dismissPopoverAnimated:NO];
    [self.settingsPopover dismissPopoverAnimated:NO];
}

- (void)changeMode:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    if(segmentedControl.selectedSegmentIndex == 0)
        [self editMode:sender];
    else
        [self playMode:sender];
}

- (IBAction)playMode:(id)sender
{
    [[mAAnalytics instance] playButton];
    
    // force load
    (void) self.view;
    
    if(self.interactionMode != MA_IM_PLAY)
    {
        [self.editor saveScript];
        
        self.interactionMode = MA_IM_PLAY;
        [self setClientViewController:self.player];
        if(self.player.allPlayers.count == 0)
            [self showMasterPopover];
        
        //        //If in portrait mode, display the master view
        //        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        //            [self.parentViewController.navigationItem.leftBarButtonItem.target performSelector:self.navigationItem.leftBarButtonItem.action withObject:self.navigationItem];
        //        }
    }
}

- (IBAction)editMode:(id)sender
{
    [[mAAnalytics instance] editButton];

    // force load
    (void) self.view;
    
    if(self.interactionMode != MA_IM_EDIT)
    {
        self.interactionMode = MA_IM_EDIT;
        [self setClientViewController:self.editor];
        [self dismissMasterPopover];
    }
}

#pragma mark - mAConsoleMonitorDelegate

- (void)consoleMonitorReceivedNewData
{
    _consoleMonitorButton.title = @"Console*";
}


#pragma mark - mAVMMonitorDelegate

- (void)vmMonitor:(mAVMMonitorController *)vmMonitor isShowingNumberOfShreds:(NSInteger)nShreds
{
    if(nShreds)
        _vmMonitorButton.title = [NSString stringWithFormat:@"Shreds (%li)", (long)nShreds];
    else
        _vmMonitorButton.title = [NSString stringWithFormat:@"Shreds"];
}


@end
