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

#import "mADirectoryViewController.h"

#import "mADetailItem.h"
#import "mADocumentManager.h"
#import "mAAnalytics.h"
#import "mAFolderTableViewCell.h"


@interface mAExpandedDirectoryListing : NSObject

+ (id)listingWithDirectoryItem:(mADetailItem *)item
                         level:(NSInteger)level;

@property (nonatomic, strong) mADetailItem *directoryItem;
@property (nonatomic) NSInteger level;

@end


static NSString *FolderCellIdentifier = @"FolderCell";
static NSString *CellIdentifier = @"Cell";

@interface mADirectoryViewController ()

@property (strong, nonatomic) NSArray *expandedDirectoryList;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIButton *addButton;

- (void)_expandDirectory:(mADetailItem *)item
                 toArray:(NSMutableArray *)list
                   level:(NSInteger)level;

@end


@implementation mADirectoryViewController

- (void)setFolder:(mADetailItem *)folder
{
    _folder = folder;
    
    NSMutableArray *list = [NSMutableArray new];
    [self _expandDirectory:_folder toArray:list level:0];
    self.expandedDirectoryList = list;
}

- (void)_expandDirectory:(mADetailItem *)item
                 toArray:(NSMutableArray *)list
                   level:(NSInteger)level
{
    [list addObject:[mAExpandedDirectoryListing listingWithDirectoryItem:item
                                                                   level:level]];
    for(mADetailItem *subitem in item.folderItems)
    {
        if(subitem.isFolder)
            [self _expandDirectory:subitem toArray:list level:level+1];
    }
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

- (UINavigationItem *)navigationItem
{
    UINavigationItem *navigationItem = super.navigationItem;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancel)];
    navigationItem.rightBarButtonItem = cancelButton;
    
    return navigationItem;
}

#pragma mark - IBActions

- (void)cancel
{
    if(self.didCancel)
        self.didCancel();
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
    return [self.expandedDirectoryList count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = indexPath.row;
    mAExpandedDirectoryListing *listing = [self.expandedDirectoryList objectAtIndex:index];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    cell.textLabel.text = listing.directoryItem.title;
    cell.indentationLevel = listing.level;
    cell.indentationWidth = 15;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = indexPath.row;
    mAExpandedDirectoryListing *listing = [self.expandedDirectoryList objectAtIndex:index];
    if(self.didChooseDirectory)
        self.didChooseDirectory(listing.directoryItem);
}

@end

@implementation mAExpandedDirectoryListing

+ (id)listingWithDirectoryItem:(mADetailItem *)item
                         level:(NSInteger)level
{
    mAExpandedDirectoryListing *obj = [mAExpandedDirectoryListing new];
    obj.directoryItem = item;
    obj.level = level;
    return obj;
}

@end


