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

#import "mASocialFileViewController.h"

#import "mADetailViewController.h"
#import "mAAnalytics.h"
#import "mASocialTableViewCell.h"
#import "mASocialDetailItem.h"
#import "mADetailItem+Social.h"
#import "mASocialCategoryViewController.h"
#import "mALoadingViewController.h"
#import "mADocumentManager.h"

#import "UIAlert.h"
#import "mAUtil.h"
#import "mAUIDef.h"

#import "ChuckpadSocial.h"
#import "Patch.h"


static NSString *SocialCellIdentifier = @"SocialCell";

NSString *mASocialCategoryGetTitle(mASocialCategory category)
{
    switch(category)
    {
        case SOCIAL_CATEGORY_ALL:
            return @"Latest";
        case SOCIAL_CATEGORY_FEATURED:
            return @"Popular";
        case SOCIAL_CATEGORY_MYPATCHES:
            return @"My Patches";
        case SOCIAL_CATEGORY_DOCUMENTATION:
            return @"Documentation";
        default:
            NSCAssert(1, @"mASocialFileViewController: invalid category");
    }
}

@interface mASocialFileViewController ()
{
    mALoadingViewController *_loadingView;
    mALoadingViewController *_messageView;
}

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UITableViewController *tableViewController;
@property (strong, nonatomic) NSArray<Patch *> *patches;

- (void)_getPatchesForCategory:(GetPatchesCallback)callback;
- (void)userLoggedIn:(NSNotification *)n;
- (void)userLoggedOut:(NSNotification *)n;
- (void)_loadPatches;
- (void)_refresh;
- (void)_showLoading:(BOOL)show;
- (void)_showLoading:(BOOL)show status:(NSString *)status;
- (void)_showMessage:(NSString *)msg;
- (void)_hideMessage;

@end


@implementation mASocialFileViewController

- (void)setCategory:(mASocialCategory)category
{
    _category = category;
    
    self.title = [mASocialCategoryGetTitle(category) uppercaseString];
}

- (void)setCategoryViewController:(mASocialCategoryViewController *)categoryViewController
{
    _categoryViewController = categoryViewController;
    [self setToolbarItems:self.categoryViewController.toolbarItems animated:NO];
}

- (void)setRefreshControl:(UIRefreshControl *)refreshControl
{
    self.tableViewController.refreshControl = refreshControl;
}

- (UIRefreshControl *)refreshControl
{
    return self.tableViewController.refreshControl;
}

- (id)init
{
    // force load from associated nib
    if(self = [self initWithNibName:@"mASocialFileViewController" bundle:nil]) { }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            self.preferredContentSize = CGSizeMake(320.0, 600.0);
        }
        
        [self setToolbarItems:self.categoryViewController.toolbarItems animated:NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedIn:)
                                                     name:CHUCKPAD_SOCIAL_LOG_IN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOut:)
                                                     name:CHUCKPAD_SOCIAL_LOG_OUT object:nil];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"mASocialTableViewCell"
                                               bundle:NULL]
         forCellReuseIdentifier:SocialCellIdentifier];
    
    self.tableView.rowHeight = 76.0;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(_refresh)
                  forControlEvents:UIControlEventValueChanged];
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

- (void)viewWillAppear:(BOOL)animated
{
    if(self.patches == nil)
        [self _loadPatches];
}

- (void)_loadPatches
{
    self.patches = nil;
    if(![self.refreshControl isRefreshing])
        [self _showLoading:YES status: @"Loading scripts"];
    
    CFTimeInterval now = CACurrentMediaTime();
    
    [self _getPatchesForCategory:^(NSArray *patchesArray, NSError *error) {
        NSAssert([NSThread isMainThread], @"Network callback not on main thread");
        
        void (^block)() = ^{
            if(error == nil)
            {
                self.patches = patchesArray;
                
                if(self.patches.count)
                {
                    [self _showLoading:NO];
                    [self.tableView reloadData];
                }
                else
                {
                    [self _showLoading:NO];
                    [self _showMessage:@"No patches found for this category."];
                }
            }
            else
            {
                mAAnalyticsLogError(error);
                [self _showLoading:NO];
                [self _showMessage:[NSString stringWithFormat:@"Failed to load patches.\n%@",
                                    error.localizedDescription]];
            }
            
            [self.refreshControl endRefreshing];
        };
        
        CFTimeInterval later = CACurrentMediaTime();
        // must take at least MIN_LOADING_TIME second(s) to reload
        if(later-now < MIN_LOADING_TIME)
            delayAnd(MIN_LOADING_TIME-(later-now), block);
        else
            block();
    }];
}

- (UINavigationItem *)navigationItem
{
    UINavigationItem *navigationItem = super.navigationItem;
    
    navigationItem.title = mASocialCategoryGetTitle(self.category);
    
    return navigationItem;
}

- (void)_getPatchesForCategory:(GetPatchesCallback)callback
{
    ChuckPadSocial *chuckPad = [ChuckPadSocial sharedInstance];
    
    switch (_category)
    {
        case SOCIAL_CATEGORY_ALL:
            [chuckPad getRecentPatches:callback];
            break;
        case SOCIAL_CATEGORY_DOCUMENTATION:
            [chuckPad getDocumentationPatches:callback];
            break;
        case SOCIAL_CATEGORY_FEATURED:
            [chuckPad getFeaturedPatches:callback];
            break;
        case SOCIAL_CATEGORY_MYPATCHES:
            if([chuckPad isLoggedIn])
            {
                [chuckPad getMyPatches:callback];
            }
            else
            {
                [self _showLoading:YES status:@"You must log in or create an account to see your patches."];
                _loadingView.loading = NO;
            }
            break;
        default:
            NSAssert(1, @"mASocialFileViewController: invalid category");
            break;
    }
}

- (void)_showLoading:(BOOL)show
{
    if(show)
    {
        if(_loadingView == nil)
        {
            _loadingView = [mALoadingViewController new];
            _loadingView.loadingViewStyle = mALoadingViewStyleTransparent;
            [self.view addSubview:_loadingView.view];
            [self.view bringSubviewToFront:_loadingView.view];
            [_loadingView fit];
        }
        
        [_loadingView show];
    }
    else
    {
        [_loadingView hide:^{
            _loadingView = nil;
            [_loadingView.view removeFromSuperview];
        }];
    }
}

- (void)_showLoading:(BOOL)show status:(NSString *)status
{
    [self _showLoading:show];
    _loadingView.status = status;
}

- (void)_showMessage:(NSString *)msg
{
    if(_messageView == nil)
    {
        _messageView = [mALoadingViewController new];
        CGRect frame = self.view.bounds;
        _messageView.view.frame = frame;
        _messageView.loadingViewStyle = mALoadingViewStyleOpaque;
        _messageView.loading = NO;
    }
    
    _messageView.status = msg;
    self.tableView.tableFooterView = _messageView.view;
    [_messageView show];
}

- (void)_hideMessage
{
    [_messageView hide:^{
        self.tableView.tableFooterView = nil;
        _messageView = nil;
    }];
}

- (void)userLoggedIn:(NSNotification *)n
{
    // clear patches
    if(self.category == SOCIAL_CATEGORY_MYPATCHES)
    {
        self.patches = nil;
        if(self.navigationController.topViewController == self)
            [self _loadPatches];
    }
}

- (void)userLoggedOut:(NSNotification *)n
{
    // clear patches
    if(self.category == SOCIAL_CATEGORY_MYPATCHES)
    {
        self.patches = nil;
        if(self.navigationController.topViewController == self)
            [self _loadPatches];
    }
}

- (void)_refresh
{
    [self _loadPatches];
}

#pragma mark - IBActions


#pragma mark - UITableViewDataSource / UITableViewDelegate

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
    if(self.patches)
        return self.patches.count;
    else
        return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return 76;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    mASocialTableViewCell *cell = (mASocialTableViewCell *) [tableView dequeueReusableCellWithIdentifier:SocialCellIdentifier];
    
    Patch *patch = self.patches[index];
    
    cell.name = patch.name;
    cell.desc = patch.patchDescription;
    cell.category = patch.creatorUsername;
    cell.numViews = patch.downloadCount;
    cell.date = [patch getTimeLastUpdatedWithPrefix:NO];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    Patch *remotePatch = self.patches[index];
    mADocumentManager *docManager = [mADocumentManager manager];
    mADetailItem *localItem = [docManager localDetailItemForSocialGUID:remotePatch.guid];
    
    // if(localItem)
    if(0) // ignore for now
    {
        // check revision numbers
        // if local item is older, ask if ok to update to latest
        // if remote item is older, open local item (ignore out-of-date remote version)
        // if both equal, open local item
        if(localItem.patch.revision < remotePatch.revision)
        {
            // show warning
        }
        else
        {
            // open local version
        }
    }
    else
    {
        mASocialDetailItem *remoteItem = [mASocialDetailItem socialDetailItemWithPatch:remotePatch];
        [self.detailViewController showDetailItem:remoteItem];
    }
}

@end

