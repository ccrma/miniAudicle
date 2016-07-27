//
//  mAMasterViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 6/28/15.
//
//

#import "mAMasterViewController.h"
#import "mAFileNavigationController.h"
#import "mADetailViewController.h"

@interface mAMasterViewController ()

@property (strong, nonatomic) IBOutlet mAFileNavigationController *fileNavigator;

@end

@implementation mAMasterViewController

- (void)setDetailViewController:(mADetailViewController *)detailViewController
{
    _detailViewController = detailViewController;
    
    self.fileNavigator.detailViewController = self.detailViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.fileNavigator.detailViewController = self.detailViewController;

    [self.fileNavigator.view setFrame:self.view.frame];
    [self.view addSubview:self.fileNavigator.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
