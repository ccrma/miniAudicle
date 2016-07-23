//
//  mAEditingBarViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/22/16.
//
//

#import "mAEditingBarViewController.h"

@interface mAEditingBarViewController ()
{
    IBOutlet UIToolbar *leftBar, *rightBar;
}

@end

@implementation mAEditingBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // this RGB gleaned with much effort from screenshots + eyeball color calibration
    // might be different for different hardware?
    self.view.backgroundColor = [UIColor colorWithRed:207/255.0 green:210/255.0 blue:214/255.0 alpha:1];
    leftBar.barTintColor = [UIColor colorWithWhite:1.0 alpha:0.0];
    rightBar.barTintColor = [UIColor colorWithWhite:1.0 alpha:0.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
