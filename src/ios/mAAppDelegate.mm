/*----------------------------------------------------------------------------
 miniAudicle iOS
 iOS GUI to chuck audio programming environment
 
 Copyright (c) 2005-2012 Spencer Salazar.  All rights reserved.
 http://chuck.cs.princeton.edu/
 http://soundlab.cs.princeton.edu/
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 U.S.A.
 -----------------------------------------------------------------------------*/

#import "mAAppDelegate.h"

#import "mAMasterViewController.h"
#import "mADetailViewController.h"
#import "mAEditorViewController.h"
#import "mAPlayerViewController.h"
#import "mADetailItem.h"
#import "mAChucKController.h"
#import "miniAudicle.h"


NSString * const kmAUserDefaultsSelectedScript = @"mAUserDefaultsSelectedScript";


@interface mAAppDelegate ()

@property (strong, nonatomic) mAMasterViewController * masterViewController;
@property (strong, nonatomic) mADetailViewController * detailViewController;
@property (strong, nonatomic) mAEditorViewController * editorViewController;
@property (strong, nonatomic) mAPlayerViewController * playerViewController;

- (NSString *)examplesPath;
- (void)appendScriptsFromDirectory:(NSString *)dir toArray:(NSMutableArray *)array;

- (NSMutableArray *)loadScripts;
- (void)saveScripts:(NSArray *)scripts;

@end


@implementation mAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.masterViewController = [[mAMasterViewController alloc] initWithNibName:@"mAMasterViewController" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.masterViewController];
        self.window.rootViewController = self.navigationController;
    } else {
        
        self.masterViewController = [[mAMasterViewController alloc] initWithNibName:@"mAMasterViewController" bundle:nil];
        UINavigationController *masterNavigationController = [[UINavigationController alloc] initWithNibName:@"mANavigationController" bundle:nil];
        [masterNavigationController pushViewController:self.masterViewController animated:NO];
        masterNavigationController.navigationBar.translucent = NO;
        
        self.detailViewController = [[mADetailViewController alloc] initWithNibName:@"mADetailViewController" bundle:nil];
    	self.editorViewController = [[mAEditorViewController alloc] initWithNibName:@"mAEditorViewController" bundle:nil];
    	self.playerViewController = [[mAPlayerViewController alloc] initWithNibName:@"mAPlayerViewController" bundle:nil];
        
        self.masterViewController.detailViewController = self.detailViewController;
        self.detailViewController.masterViewController = self.masterViewController;
        
        self.masterViewController.editorViewController = self.editorViewController;
        self.editorViewController.masterViewController = self.masterViewController;
        
        self.masterViewController.playerViewController = self.playerViewController;
        
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = self.detailViewController;
        self.splitViewController.presentsWithGesture = NO;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, self.detailViewController, nil];
        
        self.window.rootViewController = self.splitViewController;
        
        self.masterViewController.scripts = [self loadScripts];
        
        if([self.masterViewController.scripts count] < 2)
        {
            [self.masterViewController newScript];
        }
        else
        {
            [self.masterViewController selectScript:[[NSUserDefaults standardUserDefaults] integerForKey:kmAUserDefaultsSelectedScript]];
        }
    }    
    
    [self.window makeKeyAndVisible];
    
    [mAChucKController chuckController].ma->start_vm();
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    [[NSUserDefaults standardUserDefaults] setInteger:[self.masterViewController selectedScript]
                                               forKey:kmAUserDefaultsSelectedScript];
    [self saveScripts:self.masterViewController.scripts];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    
    [[NSUserDefaults standardUserDefaults] setInteger:[self.masterViewController selectedScript]
                                               forKey:kmAUserDefaultsSelectedScript];
    [self saveScripts:self.masterViewController.scripts];
}

- (NSString *)examplesPath
{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"examples"];
}

- (void)appendScriptsFromDirectory:(NSString *)dir toArray:(NSMutableArray *)array
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for(NSString *path in [fileManager contentsOfDirectoryAtPath:dir error:NULL])
    {
        BOOL isDirectory = NO;
        NSString *fullPath = [dir stringByAppendingPathComponent:path];
        
        if([[path pathExtension] isEqualToString:@"ck"])
        {
            mADetailItem *detailItem = [mADetailItem new];
            detailItem.isUser = NO;
            detailItem.title = path;
            detailItem.text = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:NULL];
            detailItem.isFolder = NO;
            detailItem.folderItems = nil;
            detailItem.path = fullPath;
            
            [array addObject:detailItem];
        }
        else if([fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory] && isDirectory)
        {
            mADetailItem *detailItem = [mADetailItem new];
            detailItem.isUser = NO;
            detailItem.title = path;
            detailItem.text = @"";
            detailItem.isFolder = YES;
            detailItem.folderItems = [NSMutableArray array];
            
            [self appendScriptsFromDirectory:fullPath toArray:detailItem.folderItems];
            
            [array addObject:detailItem];
        }
    }
}

- (NSMutableArray *)loadScripts
{
    NSMutableArray * scripts = [NSMutableArray array];
    
    NSString * path = [NSString stringWithFormat:@"%@/scripts.plist", 
                       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    NSArray * scripts2 = [NSArray arrayWithContentsOfFile:path];
    
    for(NSDictionary * item in scripts2)
    {
        [scripts addObject:[mADetailItem detailItemFromDictionary:item]];
    }
    
    NSMutableArray *examplesArray = [NSMutableArray array];
    
    [self appendScriptsFromDirectory:[self examplesPath]
                             toArray:examplesArray];
    
    [scripts addObject:[mADetailItem folderDetailItemWithTitle:@"Examples"
                                                         items:examplesArray
                                                        isUser:NO]];
    
    return scripts;
}

- (void)saveScripts:(NSArray *)scripts
{
    [self.editorViewController saveScript];
    
    NSString * path = [NSString stringWithFormat:@"%@/scripts.plist", 
                       [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
    
    NSMutableArray * scripts2 = [NSMutableArray array];
    
    for(mADetailItem * item in scripts)
    {
        if(item.isUser)
            [scripts2 addObject:[item dictionary]];
    }
    
    [scripts2 writeToFile:path atomically:YES];
}

@end



