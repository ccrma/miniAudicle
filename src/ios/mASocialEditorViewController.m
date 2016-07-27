//
//  mASocialEditorViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/26/16.
//
//

#import "mASocialEditorViewController.h"
#import "mASocialDetailItem.h"
#import "mALoadingViewController.h"
#import "mAAnalytics.h"

#import "Patch.h"

@interface mASocialEditorViewController ()

@property (strong, nonatomic) mALoadingViewController *loadingView;

- (void)showLoading:(BOOL)show;

@end

@implementation mASocialEditorViewController

- (mALoadingViewController *)loadingView
{
    if(_loadingView == nil)
    {
        _loadingView = [mALoadingViewController new];
        _loadingView.loadingViewStyle = mALoadingViewStyleTransparent;
        [self.view addSubview:_loadingView.view];
        [_loadingView fit];
    }
    
    return _loadingView;
}

- (void)setDetailItem:(mADetailItem *)detailItem
{
    if([detailItem isKindOfClass:[mASocialDetailItem class]])
    {
        mASocialDetailItem *socialItem = (mASocialDetailItem *) detailItem;
        
        // load the remote data first, if necessary
        if([socialItem isLoaded])
        {
            [super setDetailItem:socialItem];
            [self showLoading:NO];
        }
        else
        {
            // clear detail item in superclass
            [super setDetailItem:nil];
            // set title to new patch
            [self configureTitle:socialItem.patch.name editable:NO];
            
            [self showLoading:YES];
            self.loadingView.status = @"Loading script";

            [socialItem load:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(success)
                    {
                        [super setDetailItem:socialItem];
                        
                        [self showLoading:NO];
                    }
                    else
                    {
                        mAAnalyticsLogError(error);
                        self.loadingView.loading = NO;
                        self.loadingView.status = @"Failed to load script";
                    }
                });
            }];
        }
    }
    else
    {
        [super setDetailItem:detailItem];
        
        [self showLoading:NO];
    }
}

- (void)showLoading:(BOOL)show
{
    if(show)
    {
        self.loadingView.loading = YES;
        [self.loadingView show];
    }
    else
    {
        [self.loadingView hide];
        self.loadingView.loading = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
