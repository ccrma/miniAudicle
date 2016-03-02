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
#import "mADetailItem.h"
#import "mAChucKController.h"
#import "miniAudicle.h"
#import "mADocumentManager.h"
#import "mAAutocomplete.h"
#import "Crittercism.h"
#import "mAAnalytics.h"



NSString * const kmAUserDefaultsSelectedScript = @"mAUserDefaultsSelectedScript";


@interface mAAppDelegate ()

@property (strong, nonatomic) mAMasterViewController * masterViewController;
@property (strong, nonatomic) mADetailViewController * detailViewController;

@end

static mAAppDelegate *g_appDelegate = nil;

@implementation mAAppDelegate

+ (mAAppDelegate *)appDelegate
{
    return g_appDelegate;
}

- (id)init
{
    if(self = [super init])
    {
        g_appDelegate = self;
    }
    
    return self;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        self.fileViewController = [[mAFileViewController alloc] initWithNibName:@"mAFileViewController" bundle:nil];
//        self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.fileViewController];
//        self.window.rootViewController = self.navigationController;
    } else {
        self.masterViewController = [[mAMasterViewController alloc] initWithNibName:@"mAMasterViewController" bundle:nil];
        self.detailViewController = [[mADetailViewController alloc] initWithNibName:@"mADetailViewController" bundle:nil];
        
        self.masterViewController.detailViewController = self.detailViewController;
        
        self.splitViewController = [[UISplitViewController alloc] init];
        self.splitViewController.delegate = self.detailViewController;
        self.splitViewController.presentsWithGesture = NO;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:self.masterViewController, self.detailViewController, nil];
        
        self.window.rootViewController = self.splitViewController;
                
        if([[mADocumentManager manager] recentFiles].count)
            [self.detailViewController editItem:[[[mADocumentManager manager] recentFiles] firstObject]];
        else if([[mADocumentManager manager] userScripts].count)
            [self.detailViewController editItem:[[[mADocumentManager manager] userScripts] firstObject]];
        else
            [self.detailViewController editItem:[[mADocumentManager manager] newScript]];
    }
    
    [self.window makeKeyAndVisible];
    
    [mAChucKController chuckController].ma->start_vm();
    
    // create autocomplete
    mAAutocomplete::autocomplete();
    // mAAutocomplete::test();
    
    // initialize Crittericsm (crash monitoring)
    [Crittercism enableWithAppID:@"54ad8a2b3cf56b9e0457cf82"];
    
    // for testing Crittercism crash logging; do NOT commit this uncommented
    // [[NSArray arrayWithObject:@6] objectAtIndex:9];
    
    if([mAAnalytics needsOptOutSelection])
    {
#if BETA
        NSString *analyticsTitle = @"Anonymous Usage Information";
        NSString *analyticsMessage = @"Thank you for trying this beta version of miniAudicle for iPad!\n\n"
        @"To best understand how people use miniAudicle for iPad and to help improve future versions, "
        @"this app collects anonymized information about your usage of the app and shares it with the developers of the app. "
        @"The information cannot be used to identify you and does not include filenames or code text.\n\n"
        @"Given the app's beta status, your continued use of this app is taken as consent to collect this information. "
        @"Please contact the app's developers if you have any questions or concerns!";
#else
        NSString *analyticsTitle = @"Help Improve miniAudicle for iPad";
        NSString *analyticsMessage = @"Thank you for using miniAudicle for iPad!\n\n";
#endif
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:analyticsTitle
                                                                       message:analyticsMessage
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * _Nonnull action) {
                                                    [mAAnalytics setOptOut:NO];
                                                    [[mAAnalytics instance] appLaunch];
                                                }]];
        [self.window.rootViewController presentViewController:alert
                                                     animated:YES
                                                   completion:^{ }];
    }
    
    [[mAAnalytics instance] appLaunch];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    [self saveScripts];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    
    [self saveScripts];
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
    
    [self saveScripts];
}

- (void)saveScripts
{
//    [self.editorViewController saveScript];
}

@end



