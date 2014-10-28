//
//  mAActivityViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 8/5/14.
//
//

#import "mAActivityViewController.h"

@interface mAActivityViewController ()

- (IBAction)cancel:(id)sender;

@end

@implementation mAActivityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (IBAction)cancel:(id)sender
{
    if(self.cancelHandler) self.cancelHandler();
}

@end
