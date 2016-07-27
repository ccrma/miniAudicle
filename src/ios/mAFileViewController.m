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

#import "mAFileViewController.h"

#import "mADetailViewController.h"
#import "mAEditorViewController.h"
#import "mAPlayerViewController.h"
#import "mAChucKController.h"
#import "mADetailItem.h"
#import "mADocumentManager.h"
#import "mAAnalytics.h"
#import "mAAudioFileTableViewCell.h"
#import "mAFolderTableViewCell.h"
#import "mADirectoryViewController.h"
#import "UIAlert.h"
#import "mATableViewCell.h"


static NSString *CellIdentifier = @"Cell";
static NSString *AudioFileCellIdentifier = @"AudioFileCell";
static NSString *FolderCellIdentifier = @"FolderCell";


@interface mAFileViewController ()
{
    AMBlockToken *_scriptKVOBlockToken;
    BOOL _isModifyingScripts;
    NSArray *_defaultToolbarItems;
    NSArray *_editToolbarItems;
}

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) UIBarButtonItem * editButton;
@property (strong, nonatomic) NSIndexPath *activeAudioFilePath;
@property (readonly, nonatomic) NSArray *defaultToolbarItems;

@property (strong, nonatomic) mADirectoryViewController *directoryView;
//@property (strong, nonatomic) NSArray *savedNavigationViewControllers;

@property (strong, nonatomic) UIButton *addButton;
//@property (strong, nonatomic) QBPopupMenu *addMenu;

- (void)detailItemTitleChanged:(NSNotification *)n;
- (void)moveSelectedItems;
- (void)deleteSelectedItems;

@end


@implementation mAFileViewController

- (void)setFolder:(mADetailItem *)folder
{
    // remove update notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:mADetailItemTitleChangedNotification
                                                  object:nil];
    [_scriptKVOBlockToken removeObserver];
    _scriptKVOBlockToken = nil;
    
    // set value
    _folder = folder;
    
    // add update notifications
    for(mADetailItem *item in _folder.folderItems)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(detailItemTitleChanged:)
                                                     name:mADetailItemTitleChangedNotification
                                                   object:item];
    }
    
    if([_folder.folderItems isKindOfClass:[KVOMutableArray class]])
    {
        KVOMutableArray *_kvoScripts = (KVOMutableArray *)_folder.folderItems;
        _scriptKVOBlockToken = [_kvoScripts addObserverWithTask:^BOOL(id obj, NSDictionary *change) {
            if(!_isModifyingScripts)
                [self.tableView reloadData];
            return YES;
        }];
    }
    
    if(self.editable)
    {
        [self.navigationController setToolbarHidden:NO animated:YES];
        [self setToolbarItems:self.defaultToolbarItems
                     animated:YES];
    }
    else
    {
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self setToolbarItems:@[]
                     animated:YES];
    }
    
    [self.tableView reloadData];
}

- (NSArray *)defaultToolbarItems
{
    if(_defaultToolbarItems == nil)
    {
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                               target:nil action:nil];
        space.width = 10;
        
        _defaultToolbarItems = @[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                               target:nil action:nil],
                                 [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"AddFile"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self action:@selector(newScript)],
                                 space,
                                 [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"AddFolder"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self action:@selector(newFolder)]
                                 ];
    }
    return _defaultToolbarItems;
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
        
        self.folder = nil;
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"mAAudioFileTableViewCell"
                                               bundle:NULL]
         forCellReuseIdentifier:AudioFileCellIdentifier];
    [self.tableView registerNib:[UINib nibWithNibName:@"mAFolderTableViewCell"
                                               bundle:NULL]
         forCellReuseIdentifier:FolderCellIdentifier];
    
    // reload detail item
    if(self.editable)
    {
        [self.navigationController setToolbarHidden:NO animated:YES];
        [self setToolbarItems:self.defaultToolbarItems
                     animated:YES];
    }
    else
    {
        [self.navigationController setToolbarHidden:YES animated:YES];
        [self setToolbarItems:@[]
                     animated:YES];
    }
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.editable)
        [self.navigationController setToolbarHidden:NO animated:YES];
    else
        [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if(self.editable)
        [self.navigationController setToolbarHidden:YES animated:YES];

    if(self.activeAudioFilePath)
    {
        mAAudioFileTableViewCell *cell = (mAAudioFileTableViewCell *) [self.tableView cellForRowAtIndexPath:self.activeAudioFilePath];
        [cell deactivate];
    }
    
    if(self.tableView.editing)
        [self toggleEditingScripts];
}


- (void)selectScript:(int)script
{
    (void) self.view; // force the view to load
    
    if(script >= 0 && script < [self.folder.folderItems count])
    {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:script
                                                                inSection:0]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        
        mADetailItem *detailItem = [self.folder.folderItems objectAtIndex:script];
        if(!detailItem.isFolder)
           [self.detailViewController showDetailItem:detailItem];
    }
}

- (NSInteger)selectedScript
{
    return [[self.tableView indexPathForSelectedRow] row];
}


- (void)scriptsChanged
{
    // force reload
    self.folder = self.folder;
}

- (UINavigationItem *)navigationItem
{
    UINavigationItem *navigationItem = super.navigationItem;
    
    if(self.editable)
    {
        if(self.editButton == nil)
            self.editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(toggleEditingScripts)];
        navigationItem.rightBarButtonItem = self.editButton;
    }
    
    return navigationItem;
}

- (void)detailItemTitleChanged:(NSNotification *)n
{
    mADetailItem *item = [n object];
    NSUInteger index = [self.folder.folderItems indexOfObject:item];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if(!item.isFolder)
        cell.textLabel.text = item.title;
}


#pragma mark - IBActions


- (IBAction)newScript
{
    [[mAAnalytics instance] createNewScript];
    
    mADocumentManager *manager = [mADocumentManager manager];
    [self.detailViewController editItem:[manager newScriptUnderParent:self.folder]];
}

- (IBAction)newFolder
{
    [[mAAnalytics instance] createNewFolder];
    
    mADocumentManager *manager = [mADocumentManager manager];
    [manager newFolderUnderParent:self.folder];
}

- (IBAction)toggleEditingScripts
{
    [[mAAnalytics instance] editScriptList];

    if(self.tableView.isEditing)
    {
        [self.tableView setEditing:NO animated:YES];
        self.editButton.title = @"Edit";
        self.editButton.style = UIBarButtonItemStylePlain;
        
        [self setToolbarItems:_defaultToolbarItems animated:NO];
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
        self.editButton.title = @"Done";
        self.editButton.style = UIBarButtonItemStyleDone;
        
        if(_editToolbarItems == nil)
        {
            UIBarButtonItem *moveToolbarItem = [[UIBarButtonItem alloc] initWithTitle:@"Move"
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(moveSelectedItems)];
            UIBarButtonItem *deleteToolbarItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(deleteSelectedItems)];
            
            _editToolbarItems = @[moveToolbarItem,
                                  [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                                  deleteToolbarItem];
        }
        
        [self setToolbarItems:_editToolbarItems animated:YES];
    }
}

- (void)moveSelectedItems
{
    [[mAAnalytics instance] moveSelectedItems];
    
    if(self.directoryView == nil)
        self.directoryView = [[mADirectoryViewController alloc] initWithNibName:@"mADirectoryViewController" bundle:nil];
    self.directoryView.folder = [mADocumentManager manager].userScriptsFolderItem;
    
    // cache nav controller
    // (will be set to nil when self.directoryView presented)
    UINavigationController *navigationController = self.navigationController;
    // cache current nav controller stack
    NSArray *savedNavigationViewControllers = self.navigationController.viewControllers;
    // cache selected indexes
    // (will be reset when editing mode is deactivated)
    NSArray *selectedPaths = self.tableView.indexPathsForSelectedRows;
    
    __weak typeof(self) weakSelf = self;
    
    self.directoryView.didCancel = ^{
        [navigationController setViewControllers:savedNavigationViewControllers animated:YES];
        // clear - no longer needed
        weakSelf.directoryView = nil;
    };
    self.directoryView.didChooseDirectory = ^(mADetailItem *directory){
        // move the items
        
        if(directory != self.folder)
        {
            NSMutableArray *movedItems = [NSMutableArray array];
            NSMutableArray *movedIndexPaths = [NSMutableArray array];
            NSMutableArray *failedMoves = [NSMutableArray array];
            
            mADocumentManager *docManager = [mADocumentManager manager];

            for(NSIndexPath *path in selectedPaths)
            {
                NSError *error;
                mADetailItem *item = [weakSelf.folder.folderItems objectAtIndex:path.row];
                if([docManager moveItem:item toDirectory:directory error:&error])
                {
                    [movedItems addObject:[weakSelf.folder.folderItems objectAtIndex:path.row]];
                    [movedIndexPaths addObject:path];
                }
                else
                {
                    mAAnalyticsLogError(error);
                    [failedMoves addObject:item];
                }
            }
            
            // set to avoid triggering a reload of the tableview
            _isModifyingScripts = YES;
                
            for(mADetailItem *item in movedItems)
            {
                [directory.folderItems addObject:item];
                [weakSelf.folder.folderItems removeObject:item];
            }
            
            _isModifyingScripts = NO;
            
            [weakSelf.tableView deleteRowsAtIndexPaths:movedIndexPaths
                                      withRowAnimation:UITableViewRowAnimationFade];
            
            if(failedMoves.count)
            {
                NSString *failedItemsDesc;
                
                if(failedMoves.count == 1)
                {
                    failedItemsDesc = [NSString stringWithFormat:
                                       @"The following item could not be moved: %@",
                                       failedMoves[0]];
                }
                else if(failedMoves.count == 2)
                {
                    failedItemsDesc = [NSString stringWithFormat:
                                       @"The following items could not be moved: %@ and %@",
                                       failedMoves[0], failedMoves[1]];
                }
                else if(failedMoves.count == 3)
                {
                    failedItemsDesc = [NSString stringWithFormat:
                                       @"The following items could not be moved: %@, %@, and %@",
                                       failedMoves[0], failedMoves[1], failedMoves[2]];
                }
                else
                {
                    failedItemsDesc = [NSString stringWithFormat:
                                       @"The following items could not be moved: "
                                       @"%@, %@, %@, and %lu others",
                                       failedMoves[0], failedMoves[1], failedMoves[2],
                                       failedMoves.count-3];
                }
                
                UIAlertMessage2a(@"Could not move some items",
                                 failedItemsDesc,
                                 @"OK", ^{}, nil, nil);
            }
        }
        
        [navigationController setViewControllers:savedNavigationViewControllers animated:YES];
        // clear - no longer needed
        weakSelf.directoryView = nil;
    };
    
    // this will cause the current FileViewController to disappear
    // (and disengage editing mode)
    [self.navigationController setViewControllers:@[self.directoryView] animated:YES];
}

- (void)deleteSelectedItems
{
    [[mAAnalytics instance] deleteSelectedItems];
    
    _isModifyingScripts = YES;

    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *itemsToDelete = [NSMutableArray arrayWithCapacity:indexPaths.count];
    
    mADocumentManager *docManager = [mADocumentManager manager];
    for(NSIndexPath *indexPath in indexPaths)
    {
        mADetailItem *item = [self.folder.folderItems objectAtIndex:[indexPath row]];
        [itemsToDelete addObject:item];
        [docManager deleteItem:item];
    }
    
    [self.folder.folderItems removeObjectsInArray:itemsToDelete];
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
    
    _isModifyingScripts = NO;
    
    [self toggleEditingScripts];
}

#pragma mark - UITableViewDelegate

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
    return [self.folder.folderItems count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    mADetailItem *detailItem = [self.folder.folderItems objectAtIndex:index];
    
    UITableViewCell *cell = nil;
    
    if(detailItem.type == DETAILITEM_AUDIO_FILE)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:AudioFileCellIdentifier];
        if(!cell)
        {
            // uh
            assert(0);
        }
        
        cell.textLabel.text = detailItem.title;
    }
    else if(detailItem.isFolder)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:FolderCellIdentifier];
        if(!cell)
        {
            // uh
            assert(0);
        }
        
        mAFolderTableViewCell *folderCell = (mAFolderTableViewCell *) cell;
        folderCell.item = detailItem;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil)
        {
            cell = [[mATableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        if(detailItem.type != DETAILITEM_CHUCK_SCRIPT)
            cell.textLabel.textColor = [UIColor grayColor];
        else
            cell.textLabel.textColor = [UIColor blackColor];
        
        mATableViewCell *itemCell = (mATableViewCell *) cell;
        itemCell.item = detailItem;
    }

    if(detailItem.isFolder)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.tableView.isEditing)
        return;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController) {
	        self.detailViewController = [[mADetailViewController alloc] initWithNibName:@"mADetailViewController" bundle:nil];
	    }
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    }
    else
    {
        NSInteger index = indexPath.row;
        mADetailItem *detailItem = [self.folder.folderItems objectAtIndex:index];
        
        if(detailItem.type == DETAILITEM_CHUCK_SCRIPT)
        {
            [self.detailViewController showDetailItem:detailItem];
        }
        else if(detailItem.type == DETAILITEM_AUDIO_FILE)
        {
            mAAudioFileTableViewCell *activeCell = (mAAudioFileTableViewCell *) [self.tableView cellForRowAtIndexPath:indexPath];
            mAAudioFileTableViewCell *oldCell = nil;
            
            if(self.activeAudioFilePath)
                oldCell = (mAAudioFileTableViewCell *) [self.tableView cellForRowAtIndexPath:self.activeAudioFilePath];
            
            if(oldCell != activeCell)
            {
                [oldCell deactivate];
                [activeCell activate];
            }
            
            [activeCell playDetailItem:detailItem];
            
            self.activeAudioFilePath = indexPath;
        }
        else if(detailItem.type == DETAILITEM_DIRECTORY)
        {
            mAFileViewController *fileView = [[mAFileViewController alloc] initWithNibName:@"mAFileViewController" bundle:nil];
            
            fileView.detailViewController = self.detailViewController;
            fileView.navigationItem.title = detailItem.title;
            fileView.folder = detailItem;
            fileView.editable = detailItem.isUser;
            
            [self.navigationController pushViewController:fileView animated:YES];
        }
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    mADetailItem *detailItem = [self.folder.folderItems objectAtIndex:index];
    
    if(detailItem.isUser)
        return UITableViewCellEditingStyleDelete;
    else
        return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView 
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle 
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete)
    {
        _isModifyingScripts = YES;

        mADetailItem *item = [self.folder.folderItems objectAtIndex:[indexPath row]];
        
        [[mAAnalytics instance] deleteFromScriptList:item.uuid];
        
        [[mADocumentManager manager] deleteItem:item];
        
        [self.folder.folderItems removeObjectAtIndex:[indexPath row]];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
        
        _isModifyingScripts = NO;
    }
}

@end

