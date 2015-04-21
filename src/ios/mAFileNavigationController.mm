//
//  mAFileNavigationController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 1/7/15.
//
//

#import "mAFileNavigationController.h"
#import "mADocumentManager.h"
#import "mAFileViewController.h"


@interface mAFileNavigationController ()
{
    IBOutlet UISegmentedControl *segmentedControl;
}

@property (strong, nonatomic) IBOutlet UIView *contentView;

- (void)adjustNavigationBar:(UIViewController *)targetViewController animated:(BOOL)animated;
- (IBAction)selectedMode:(id)sender;

@end

@implementation mAFileNavigationController

- (void)setChildNavigationController:(UINavigationController *)childNavigationController
{
    // remove existing child views
    if([self isViewLoaded])
    {
        for(UIView *subview in self.contentView.subviews)
            [subview removeFromSuperview];
    }
    
    _childNavigationController = childNavigationController;
    _childNavigationController.delegate = self;
    if(_childNavigationController.viewControllers.count)
    {
        // make navigation appear/disappear as needed
        [self adjustNavigationBar:[_childNavigationController.viewControllers lastObject] animated:NO];
    }
    
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
    [self.childNavigationController setViewControllers:@[self.myScriptsViewController] animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(recentFilesChanged:)
                                                 name:mADocumentManagerRecentFilesChanged
                                               object:[mADocumentManager manager]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)selectedMode:(id)sender
{
    switch([segmentedControl selectedSegmentIndex])
    {
        case 0:
            [self.childNavigationController setViewControllers:@[self.myScriptsViewController] animated:NO];
            break;
        case 1:
            [self.childNavigationController setViewControllers:@[self.recentViewController] animated:NO];
            break;
        case 2:
            [self.childNavigationController setViewControllers:@[self.examplesViewController] animated:NO];
            break;
        default: ; // uhh
    }
}

- (void)adjustNavigationBar:(UIViewController *)targetViewController animated:(BOOL)animated
{
    if(targetViewController == _childNavigationController.viewControllers[0] &&
//       !(targetViewController.navigationItem.leftBarButtonItems.count || targetViewController.navigationItem.leftBarButtonItem ||
//         targetViewController.navigationItem.rightBarButtonItems.count || targetViewController.navigationItem.rightBarButtonItem))
       !(targetViewController.navigationItem.leftBarButtonItems.count || targetViewController.navigationItem.rightBarButtonItems.count ))
        [_childNavigationController setNavigationBarHidden:YES animated:animated];
    else
        [_childNavigationController setNavigationBarHidden:NO animated:animated];
}

- (void)recentFilesChanged:(NSNotification *)n
{
    [self.recentViewController scriptsChanged];
}


#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    [self adjustNavigationBar:viewController animated:animated];
}


@end
