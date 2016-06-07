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
#import "miniAudicle.h"
#import "mADetailItem.h"
#import "mADocumentManager.h"
#import "mAAnalytics.h"
#import "mAAudioFileTableViewCell.h"
#import "mAFolderTableViewCell.h"
#import "QBPopupMenu.h"


static NSString *CellIdentifier = @"Cell";
static NSString *AudioFileCellIdentifier = @"AudioFileCell";
static NSString *FolderCellIdentifier = @"FolderCell";


@interface mAFileViewController ()
{
    AMBlockToken *_scriptKVOBlockToken;
    BOOL _isDeletingScript;
    NSArray *_defaultRowActions;
    NSArray *_editToolbarItems;
}

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) UIBarButtonItem * editButton;
@property (strong, nonatomic) NSIndexPath *activeAudioFilePath;

@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) QBPopupMenu *addMenu;

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
            if(!_isDeletingScript)
                [self.tableView reloadData];
            return YES;
        }];
    }
    
    [self.tableView reloadData];
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
    [self.navigationController setToolbarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:animated];

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

- (int)selectedScript
{
    return [[self.tableView indexPathForSelectedRow] row];
}


//- (void)scriptDetailChanged
//{
////    int row = [self selectedScript];
////    [self.tableView reloadData];
////    [self selectScript:row];
//    
//    // reload name
//    [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]].textLabel.text = self.editorViewController.detailItem.title;
//}

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
//        self.addButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [self.addButton setImage:[UIImage imageNamed:@"AddFile"] forState:UIControlStateNormal];
//        [self.addButton sizeToFit];
//        CGRect frame = self.addButton.frame;
//        frame.size.width *= 1.5;
//        [self.addButton setFrame:frame];
//        self.addButton.titleLabel.font = [UIFont systemFontOfSize:38 weight:UIFontWeightUltraLight];
//        self.addButton.titleLabel.textColor = self.view.tintColor;
//        [self.addButton addTarget:self action:@selector(newScript) forControlEvents:UIControlEventTouchUpInside];
//        
//        UIButton *_addFolderButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        [_addFolderButton setImage:[UIImage imageNamed:@"AddFolder"] forState:UIControlStateNormal];
//        [_addFolderButton sizeToFit];
//        frame = _addFolderButton.frame;
//        frame.size.width *= 1.5;
//        [_addFolderButton setFrame:frame];
//        [_addFolderButton addTarget:self action:@selector(newFolder) forControlEvents:UIControlEventTouchUpInside];
//        
//        navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithCustomView:self.addButton],
//                                               [[UIBarButtonItem alloc] initWithCustomView:_addFolderButton]];
        
//        navigationItem.rightBarButtonItems = @[[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"AddFile"]
//                                                                                style:UIBarButtonItemStylePlain
//                                                                               target:self
//                                                                               action:@selector(newScript)],
//                                               [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"AddFolder"]
//                                                                                style:UIBarButtonItemStylePlain
//                                                                               target:self
//                                                                               action:@selector(newFolder)]];
        
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
    int index = [self.folder.folderItems indexOfObject:item];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if(!item.isFolder)
        cell.textLabel.text = item.title;
}


#pragma mark - IBActions


- (IBAction)newScript
{
    //    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:insertIndex inSection:0]
    //                                animated:YES
    //                          scrollPosition:UITableViewScrollPositionNone];
    [[mAAnalytics instance] createNewScript];
    
    mADocumentManager *manager = [mADocumentManager manager];
    [self.detailViewController editItem:[manager newScriptUnderParent:self.folder]];
}

- (IBAction)newFolder
{
    [[mAAnalytics instance] createNewFolder];
    // TODO: analytics
    
    mADocumentManager *manager = [mADocumentManager manager];
    [manager newFolderUnderParent:self.folder];
}

- (IBAction)openAddMenu
{
    if(self.addMenu == nil)
    {
        QBPopupMenuItem *addScriptItem = [QBPopupMenuItem itemWithTitle:@"Script" target:self action:@selector(newScript)];
        QBPopupMenuItem *addFolderItem = [QBPopupMenuItem itemWithTitle:@"Folder" target:self action:@selector(newFolder)];
        
        self.addMenu = [[QBPopupMenu alloc] initWithItems:@[addScriptItem, addFolderItem]];
        self.addMenu.arrowDirection = QBPopupMenuArrowDirectionRight;
    }
    
    [self.addMenu showInView:self.addButton.superview targetRect:self.addButton.frame animated:YES];
}

- (IBAction)toggleEditingScripts
{
    [[mAAnalytics instance] editScriptList];

    if(self.tableView.isEditing)
    {
        [self.tableView setEditing:NO animated:YES];
        self.editButton.title = @"Edit";
        self.editButton.style = UIBarButtonItemStylePlain;
        
        [self setToolbarItems:@[] animated:NO];
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
    // TODO: analytics
    
    //[self toggleEditingScripts];
}

- (void)deleteSelectedItems
{
    // TODO: analytics
    
    _isDeletingScript = YES;

    NSArray *indexPaths = [self.tableView indexPathsForSelectedRows];
    NSMutableArray *itemsToDelete = [NSMutableArray arrayWithCapacity:indexPaths.count];
    
    for(NSIndexPath *indexPath in indexPaths)
    {
        mADetailItem *item = [self.folder.folderItems objectAtIndex:[indexPath row]];
        [itemsToDelete addObject:item];
        [[mADocumentManager manager] deleteItem:item];
    }
    
    [self.folder.folderItems removeObjectsInArray:itemsToDelete];
    
    [self.tableView deleteRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationFade];
    
    _isDeletingScript = NO;
    
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
    int index = indexPath.row;
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
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
        }
        
        cell.textLabel.text = detailItem.title;
        if(detailItem.type != DETAILITEM_CHUCK_SCRIPT)
            cell.textLabel.textColor = [UIColor grayColor];
        else
            cell.textLabel.textColor = [UIColor blackColor];
    }

    if(detailItem.isFolder)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if(_defaultRowActions == nil)
//    {
//        UITableViewRowAction *moveAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
//                                                                              title:@"Move"
//                                                                            handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//                                                                                
//                                                                            }];
//        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
//                                                                                title:@"Delete"
//                                                                              handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//                                                                                  
//                                                                              }];
//        _defaultRowActions = @[moveAction, deleteAction];
//    }
//    
//    return _defaultRowActions;
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    int index = indexPath.row;
    mADetailItem *detailItem = [self.folder.folderItems objectAtIndex:index];
    
    return detailItem.isFolder;
}
*/
/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
        int index = indexPath.row;
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
    int index = indexPath.row;
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
        _isDeletingScript = YES;

        mADetailItem *item = [self.folder.folderItems objectAtIndex:[indexPath row]];
        
        [[mAAnalytics instance] deleteFromScriptList:item.uuid];
        
        [[mADocumentManager manager] deleteItem:item];
        
        [self.folder.folderItems removeObjectAtIndex:[indexPath row]];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
        
        _isDeletingScript = NO;
    }
}

@end

