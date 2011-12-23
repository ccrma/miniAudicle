//
//  mAMasterViewController.m
//  miniAudicle iOS
//
//  Created by Spencer Salazar on 12/20/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "mAMasterViewController.h"

#import "mADetailViewController.h"
#import "mAChucKController.h"
#import "miniAudicle.h"


@interface mAMasterViewController ()

@property (strong, nonatomic) UITableView * tableView;

@end


@implementation mAMasterViewController

@synthesize scripts = _scripts;
@synthesize detailViewController = _detailViewController;
@synthesize tableView = _tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self)
    {
        self.title = NSLocalizedString(@"Scripts", @"Scripts");
        if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
//            self.clearsSelectionOnViewWillAppear = NO;
            self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
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
    if(script >= 0 && script < [self.scripts count])
    {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:script
                                                                inSection:0]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
    }
}

- (int)selectedScript
{
    return [[self.tableView indexPathForSelectedRow] row];
}


- (void)scriptDetailChanged
{
    [self.tableView reloadData];
}


#pragma mark IBActions

- (IBAction)newScript
{
    mADetailItem * detailItem = [mADetailItem new];
    
    detailItem.title = [NSString stringWithFormat:@"Untitled %i", untitledNumber++];
    detailItem.text = @"";
    detailItem.docid = [mAChucKController chuckController].ma->allocate_document_id();
    
    int insertIndex = 0;
    
    [self.scripts insertObject:detailItem atIndex:insertIndex];
    [self.tableView reloadData];
    
    self.detailViewController.detailItem = detailItem;
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:insertIndex inSection:0] 
                                animated:YES
                          scrollPosition:UITableViewScrollPositionNone];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] 
                                    animated:NO 
                              scrollPosition:UITableViewScrollPositionMiddle];
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

    // Configure the cell.
    int index = indexPath.row;
    cell.textLabel.text = [[self.scripts objectAtIndex:index] title];
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
	        self.detailViewController = [[mADetailViewController alloc] initWithNibName:@"mADetailViewController_iPhone" bundle:nil];
	    }
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    }
    else
    {
        int index = indexPath.row;
        self.detailViewController.detailItem = [self.scripts objectAtIndex:index];
    }
}

@end
