//
//  mASocialCategoryTableViewController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/25/16.
//
//

#import "mASocialCategoryViewController.h"
#import "mASocialFileViewController.h"
#import "mASocialLoginViewController.h"

@interface mASocialCategoryViewController ()
{
    NSArray<NSString *> *_categories;
}

@property (strong, nonatomic) mASocialFileViewController *allSocialFileViewController;
@property (strong, nonatomic) mASocialFileViewController *featuredSocialFileViewController;
@property (strong, nonatomic) mASocialFileViewController *documentationSocialFileViewController;
@property (strong, nonatomic) mASocialFileViewController *mySocialFileViewController;

@property (strong, nonatomic) mASocialLoginViewController *loginView;

@end

@implementation mASocialCategoryViewController

- (mASocialFileViewController *)allSocialFileViewController
{
    if(_allSocialFileViewController == nil)
    {
        _allSocialFileViewController = [mASocialFileViewController new];
        _allSocialFileViewController.category = SOCIAL_CATEGORY_ALL;
        _allSocialFileViewController.detailViewController = self.detailViewController;
        _allSocialFileViewController.categoryViewController = self;
    }
    
    return _allSocialFileViewController;
}

- (mASocialFileViewController *)featuredSocialFileViewController
{
    if(_featuredSocialFileViewController == nil)
    {
        _featuredSocialFileViewController = [mASocialFileViewController new];
        _featuredSocialFileViewController.category = SOCIAL_CATEGORY_FEATURED;
        _featuredSocialFileViewController.detailViewController = self.detailViewController;
        _featuredSocialFileViewController.categoryViewController = self;
    }
    
    return _featuredSocialFileViewController;
}

- (mASocialFileViewController *)documentationSocialFileViewController
{
    if(_documentationSocialFileViewController == nil)
    {
        _documentationSocialFileViewController = [mASocialFileViewController new];
        _documentationSocialFileViewController.category = SOCIAL_CATEGORY_DOCUMENTATION;
        _documentationSocialFileViewController.detailViewController = self.detailViewController;
        _documentationSocialFileViewController.categoryViewController = self;
    }
    
    return _documentationSocialFileViewController;
}

- (mASocialFileViewController *)mySocialFileViewController
{
    if(_mySocialFileViewController == nil)
    {
        _mySocialFileViewController = [mASocialFileViewController new];
        _mySocialFileViewController.category = SOCIAL_CATEGORY_MYPATCHES;
        _mySocialFileViewController.detailViewController = self.detailViewController;
        _mySocialFileViewController.categoryViewController = self;
    }
    
    return _mySocialFileViewController;
}

- (mASocialLoginViewController *)loginView
{
    if(_loginView == nil)
    {
        _loginView = [mASocialLoginViewController new];
    }
    
    return _loginView;
}

- (id)init
{
    if(self = [super initWithStyle:UITableViewStylePlain])
    {
        _categories = @[ @(SOCIAL_CATEGORY_ALL),
                         @(SOCIAL_CATEGORY_FEATURED),
                         @(SOCIAL_CATEGORY_DOCUMENTATION),
                         @(SOCIAL_CATEGORY_MYPATCHES), ];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Chuckpad Social Scripts";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (UINavigationItem *)navigationItem
{
    UINavigationItem *navigationItem = super.navigationItem;
    
    UIBarButtonItem *loginItem = [[UIBarButtonItem alloc] initWithTitle:@"Login"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(loginOrRegister)];
    navigationItem.rightBarButtonItem = loginItem;
    
    return navigationItem;
}

- (mASocialFileViewController *)defaultCategoryViewController
{
    return self.allSocialFileViewController;
}

- (void)loginOrRegister
{
    [self.loginView clearFields];
    [self presentViewController:self.loginView animated:YES completion:^{}];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    mASocialCategory category = (mASocialCategory) [_categories[index] intValue];
//    NSMutableAttributedString *attrTitle;
//    attrTitle = [[NSMutableAttributedString alloc] initWithString:[mASocialCategoryGetTitle(category) uppercaseString]
//                                                       attributes:@{ NSKernAttributeName: @2 }];
//    
//    cell.textLabel.attributedText = attrTitle;
    cell.textLabel.text = mASocialCategoryGetTitle(category);
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    switch((mASocialCategory)[_categories[index] intValue])
    {
        case SOCIAL_CATEGORY_ALL:
            [self.navigationController pushViewController:self.allSocialFileViewController animated:YES];
            break;
        case SOCIAL_CATEGORY_FEATURED:
            [self.navigationController pushViewController:self.featuredSocialFileViewController animated:YES];
            break;
        case SOCIAL_CATEGORY_DOCUMENTATION:
            [self.navigationController pushViewController:self.documentationSocialFileViewController animated:YES];
            break;
        case SOCIAL_CATEGORY_MYPATCHES:
            [self.navigationController pushViewController:self.mySocialFileViewController animated:YES];
            break;
        default:
            NSAssert(1, @"mASocialFileViewController: invalid category");
    }
}

@end
