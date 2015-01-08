//
//  mAMasterNavigationController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 1/7/15.
//
//

#import "mAMasterNavigationController.h"

@interface mAMasterNavigationController ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

- (IBAction)selectedMode:(id)sender;

@end

@implementation mAMasterNavigationController

- (void)setChildNavigationController:(UINavigationController *)childNavigationController
{
    // remove existing child views
    if([self isViewLoaded])
    {
        for(UIView *subview in self.contentView.subviews)
            [subview removeFromSuperview];
    }
    
    _childNavigationController = childNavigationController;
    
    // add to contentView
    if([self isViewLoaded] && _childNavigationController != nil)
    {
        _childNavigationController.view.frame = self.contentView.bounds;
        [self.contentView addSubview:_childNavigationController.view];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // reset to add subview to contentView
    self.childNavigationController = self.childNavigationController;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectedMode:(id)sender
{
    
}


@end
