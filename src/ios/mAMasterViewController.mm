//
//  mAMasterViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 6/28/15.
//
//

#import "mAMasterViewController.h"
#import "mAFileNavigationController.h"

@interface mAMasterViewController ()

@end

@implementation mAMasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self.fileNavigator.view setFrame:self.view.frame];
    [self.view addSubview:self.fileNavigator.view];
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
