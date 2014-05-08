//
//  mALoopCountPicker.m
//  miniAudicle
//
//  Created by Spencer Salazar on 5/5/14.
//
//

#import "mALoopCountPicker.h"

@interface mALoopCountPicker ()
{
    NSInteger _pickedRow;
}

@end

@implementation mALoopCountPicker

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (CGSize)preferredContentSize
{
    return CGSizeMake(120, 216);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)ok:(id)sender
{
    if(self.pickedLoopCount)
        self.pickedLoopCount(_pickedRow+1);
}

- (IBAction)pressed:(id)sender
{
    if(self.pickedLoopCount)
        self.pickedLoopCount([sender tag]+1);
}


#pragma mark - UITableViewDataSource / UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 64;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"mALoopCountPickerCell"];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"mALoopCountPickerCell"];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%i", (int) (indexPath.row+1)];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.pickedLoopCount)
        self.pickedLoopCount(indexPath.row+1);
}

#pragma mark - UIPopoverControllerDelegate

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    if(self.cancelled)
        self.cancelled();
    
    return YES;
}

@end
