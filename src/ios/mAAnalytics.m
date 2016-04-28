//
//  mAAnalytics.m
//  miniAudicle
//
//  Created by Spencer Salazar on 2/28/16.
//
//

#import "mAAnalytics.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#define VERBOSE_LOGGING 0

//static NSString * const mAAnalyticsNeedsOptOutSelection = @"mAAnalyticsNeedsOptOutSelection";
static NSString * const mAAnalyticsOptOut = @"mAAnalyticsOptOut";

@interface mAAnalytics ()
{
    BOOL _lastActionWasEdit;
}

- (id<GAITracker>)tracker;

@end

@implementation mAAnalytics

+ (instancetype)instance
{
    static mAAnalytics *_instance = nil;
    
    @synchronized(self)
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        // return nil of opt-out has not been set one way or another
        if([userDefaults objectForKey:mAAnalyticsOptOut] == nil)
            return nil;
        // return nil if opt-out has been set to true
        if([userDefaults boolForKey:mAAnalyticsOptOut])
            return nil;
        
        if(_instance == nil)
            _instance = [mAAnalytics new];
    }
    
    return _instance;
}

+ (BOOL)needsOptOutSelection
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if([userDefaults objectForKey:mAAnalyticsOptOut] == nil)
        return YES;
    else
        return NO;
}

+ (void)setOptOut:(BOOL)optOut
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:optOut forKey:mAAnalyticsOptOut];
    [userDefaults synchronize];
}

- (id)init
{
    if(self = [super init])
    {
        // set up Google Analytics
        // Initialize the default tracker. After initialization, [GAI sharedInstance].defaultTracker
        // returns this same tracker.
        // TODO: Replace the tracker-id with your app one from https://www.google.com/analytics/web/
        NSString *trackingId = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"GAITrackingID"];
        (void) [[GAI sharedInstance] trackerWithTrackingId:trackingId];
        
        // Provide unhandled exceptions reports.
#if !DEBUG || VERBOSE_LOGGING
        GAI *gai = [GAI sharedInstance];
#if !DEBUG
        gai.trackUncaughtExceptions = YES;
#endif
#if VERBOSE_LOGGING
        gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
#endif // VERBOSE_LOGGING
#endif

        _lastActionWasEdit = NO;
    }
    
    return self;
}

- (id<GAITracker>)tracker
{
    return [GAI sharedInstance].defaultTracker;
}

- (void)logError:(NSError *)error
        function:(const char *)func
            line:(int)line;
{
    NSString *errorDescription = [NSString stringWithFormat:@"Received error on %s:%i: %@", func, line, error];
    NSLog(@"%@", errorDescription);
    [self.tracker send:[[GAIDictionaryBuilder createExceptionWithDescription:errorDescription
                                                                   withFatal:@NO] build]];
}

- (void)editorScreen
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Editor"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)playerScreen
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Player"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

- (void)appLaunch
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"General"
                                                               action:@"AppLaunch"
                                                                label:@""
                                                                value:@1] build]];
}

- (void)editButton
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"General"
                                                               action:@"EnterEditMode"
                                                                label:@""
                                                                value:@1] build]];
}

- (void)playButton
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"General"
                                                               action:@"EnterPlayMode"
                                                                label:@""
                                                                value:@1] build]];
}

- (void)consoleButton
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"General"
                                                               action:@"ConsoleOpen"
                                                                label:@""
                                                                value:@1] build]];
}

- (void)shredsButton
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"General"
                                                               action:@"ShredsOpen"
                                                                label:@""
                                                                value:@1] build]];
}

- (void)settingsButton
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"General"
                                                               action:@"SettingsOpen"
                                                                label:@""
                                                                value:@1] build]];
}

- (void)myScripts
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"General"
                                                               action:@"MyScripts"
                                                                label:@""
                                                                value:@1] build]];
}

- (void)recentScripts
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"General"
                                                               action:@"RecentScripts"
                                                                label:@""
                                                                value:@1] build]];
}

- (void)exampleScripts
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"General"
                                                               action:@"ExampleScripts"
                                                                label:@""
                                                                value:@1] build]];
}

- (void)createNewScript
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"General"
                                                               action:@"NewScript"
                                                                label:@""
                                                                value:@1] build]];
}

- (void)editScriptList
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"General"
                                                               action:@"EditScriptList"
                                                                label:@""
                                                                value:@1] build]];
}

- (void)deleteFromScriptList:(NSString *)file
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"General"
                                                               action:@"DeleteFromScriptList"
                                                                label:file
                                                                value:@1] build]];
}


- (void)editAddButton:(NSString *)file
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"EditMode"
                                                               action:@"AddShred"
                                                                label:file
                                                                value:@1] build]];
}

- (void)editReplaceButton:(NSString *)file
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"EditMode"
                                                               action:@"ReplaceShred"
                                                                label:file
                                                                value:@1] build]];
}

- (void)editRemoveButton:(NSString *)file
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"EditMode"
                                                               action:@"RemoveShred"
                                                                label:file
                                                                value:@1] build]];
}

- (void)editEditScript:(NSString *)file
{
    // only record start of editing
    if(_lastActionWasEdit) return;
    
    _lastActionWasEdit = YES;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"EditMode"
                                                               action:@"EditScript"
                                                                label:file
                                                                value:@1] build]];
}

- (void)editTitleButton:(NSString *)file
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"EditMode"
                                                               action:@"Title"
                                                                label:file
                                                                value:@1] build]];
}


- (void)playAddButton:(NSString *)file
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PlayMode"
                                                               action:@"AddShred"
                                                                label:file
                                                                value:@1] build]];
}

- (void)playAddScript:(NSString *)file
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PlayMode"
                                                               action:@"AddShred"
                                                                label:file
                                                                value:@1] build]];
}

- (void)playReplaceButton:(NSString *)file
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PlayMode"
                                                               action:@"ReplaceShred"
                                                                label:file
                                                                value:@1] build]];
}

- (void)playRemoveButton:(NSString *)file
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PlayMode"
                                                               action:@"RemoveShred"
                                                                label:file
                                                                value:@1] build]];
}

- (void)playEditButton:(NSString *)file
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PlayMode"
                                                               action:@"EditScript"
                                                                label:file
                                                                value:@1] build]];
}

- (void)playDeleteButton:(NSString *)file
{
    _lastActionWasEdit = NO;
    
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"PlayMode"
                                                               action:@"DeletePlayer"
                                                                label:file
                                                                value:@1] build]];
}

@end
