//
//  mAKeyboardAccessoryViewViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/22/14.
//
//

#import "mAKeyboardAccessoryViewController.h"

@interface mAKeyboardAccessoryViewController ()

@end

@implementation mAKeyboardAccessoryViewController

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

- (IBAction)keyPressed:(id)sender
{
    [self.delegate keyPressed:[sender currentTitle]];
}

@end
