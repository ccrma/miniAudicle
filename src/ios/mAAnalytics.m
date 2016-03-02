//
//  mAAnalytics.m
//  miniAudicle
//
//  Created by Spencer Salazar on 2/28/16.
//
//

#import "mAAnalytics.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

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
        if(_instance == nil)
        {
            _instance = [mAAnalytics new];
        }
    }
    return _instance;
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
        GAI *gai = [GAI sharedInstance];
        gai.trackUncaughtExceptions = YES;
        gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
        
        _lastActionWasEdit = NO;
    }
    
    return self;
}

- (id<GAITracker>)tracker
{
    return [GAI sharedInstance].defaultTracker;
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
