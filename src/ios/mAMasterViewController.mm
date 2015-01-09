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

#import "mAMasterViewController.h"

#import "mADetailViewController.h"
#import "mAEditorViewController.h"
#import "mAPlayerViewController.h"
#import "mAChucKController.h"
#import "miniAudicle.h"
#import "mADetailItem.h"
#import "mADocumentManager.h"

enum mAInteractionMode
{
    MA_IM_NONE,
    MA_IM_EDIT,
    MA_IM_PLAY,
};

static mAInteractionMode g_mode = MA_IM_NONE;


@interface mAMasterViewController ()

@property (strong, nonatomic) UITableView * tableView;
@property (strong, nonatomic) UIBarButtonItem * editButton;

@end


@implementation mAMasterViewController

@synthesize scripts = _scripts;
@synthesize detailViewController = _detailViewController;
@synthesize tableView = _tableView, editButton = _editButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
//        self.title = NSLocalizedString(@"Scripts", @"Scripts");
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            self.preferredContentSize = CGSizeMake(320.0, 600.0);
        }
        
        self.scripts = [NSMutableArray new];
        untitledNumber = 1;
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


- (void)selectScript:(int)script
{
    (void) self.view; // force the view to load
    
    if(script >= 0 && script < [self.scripts count])
    {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:script
                                                                inSection:0]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        
        mADetailItem *detailItem = [self.scripts objectAtIndex:script];
        if(!detailItem.isFolder)
            self.editorViewController.detailItem = detailItem;
    }
}

- (int)selectedScript
{
    return [[self.tableView indexPathForSelectedRow] row];
}


- (void)scriptDetailChanged
{
//    int row = [self selectedScript];
//    [self.tableView reloadData];
//    [self selectScript:row];
    
    // reload name
    [self.tableView cellForRowAtIndexPath:[self.tableView indexPathForSelectedRow]].textLabel.text = self.editorViewController.detailItem.title;
}

- (UINavigationItem *)navigationItem
{
    UINavigationItem *navigationItem = super.navigationItem;
    
    if(self.editable)
    {
        navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                          target:self
                                                                                          action:@selector(newScript)];
    }
    
    return navigationItem;
}


#pragma mark - IBActions

- (IBAction)newScript
{
    (void) self.view; // force the view to load
    
    
    mADetailItem *detailItem = [[mADocumentManager manager] newScript:[NSString stringWithFormat:@"Untitled %i", untitledNumber++]];
    detailItem.docid = [mAChucKController chuckController].ma->allocate_document_id();
    
    int insertIndex = 0;
    
    [self.scripts insertObject:detailItem atIndex:insertIndex];
    [self.tableView reloadData];
    
    self.editorViewController.detailItem = detailItem;
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:insertIndex inSection:0] 
                                animated:YES
                          scrollPosition:UITableViewScrollPositionNone];
}


- (IBAction)editScripts
{
    if(self.tableView.isEditing)
    {
        [self.tableView setEditing:NO animated:YES];
        self.editButton.title = @"Edit";
        self.editButton.style = UIBarButtonItemStyleBordered;
    }
    else
    {
        [self.tableView setEditing:YES animated:YES];
        self.editButton.title = @"Done";
        self.editButton.style = UIBarButtonItemStyleDone;
    }
}

- (IBAction)playMode:(id)sender
{
    if(g_mode != MA_IM_PLAY)
    {
        [self.editorViewController saveScript];
        
        g_mode = MA_IM_PLAY;
        [self.detailViewController setClientViewController:self.playerViewController];
        [self.detailViewController dismissMasterPopover];
    }
}

- (IBAction)editMode:(id)sender
{
    if(g_mode != MA_IM_EDIT)
    {
        g_mode = MA_IM_EDIT;
        [self.detailViewController setClientViewController:self.editorViewController];
        [self.detailViewController dismissMasterPopover];
    }
}


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//        if(self.scripts.count)
//            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
//                                        animated:NO
//                                  scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
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

#pragma mark - UITableViewDelegate

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView 
 numberOfRowsInSection:(NSInteger)section
{
    return [self.scripts count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    
    int index = indexPath.row;
    mADetailItem *detailItem = [self.scripts objectAtIndex:index];

    // Configure the cell.
    cell.textLabel.text = detailItem.title;
    
    if(detailItem.isFolder)
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController) {
	        self.detailViewController = [[mADetailViewController alloc] initWithNibName:@"mADetailViewController" bundle:nil];
	    }
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    }
    else
    {
        int index = indexPath.row;
        mADetailItem *detailItem = [self.scripts objectAtIndex:index];
        
        if(!detailItem.isFolder)
        {
            if(g_mode == MA_IM_EDIT)
            {
                self.editorViewController.detailItem = detailItem;
                [self.detailViewController dismissMasterPopover];
            }
            else
            {
                [self.playerViewController addScript:detailItem];
//                [self.detailViewController dismissMasterPopover];
            }
        }
        else
        {
            mAMasterViewController *master = [[mAMasterViewController alloc] initWithNibName:@"mAMasterViewController" bundle:nil];
            
            master.detailViewController = self.detailViewController;
            master.editorViewController = self.editorViewController;
            master.playerViewController = self.playerViewController;
            master.navigationItem.title = detailItem.title;
            master.scripts = detailItem.folderItems;
            
            [self.navigationController pushViewController:master animated:YES];
        }
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index = indexPath.row;
    mADetailItem *detailItem = [self.scripts objectAtIndex:index];
    
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
        mADetailItem *item = [self.scripts objectAtIndex:[indexPath row]];
        [[mADocumentManager manager] deleteScript:item];
        [self.scripts removeObjectAtIndex:[indexPath row]];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                              withRowAnimation:UITableViewRowAnimationFade];
    }
}


@end
