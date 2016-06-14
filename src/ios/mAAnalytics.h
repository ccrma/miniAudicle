//
//  mAAnalytics.h
//  miniAudicle
//
//  Created by Spencer Salazar on 2/28/16.
//
//

#import <Foundation/Foundation.h>

#define mAAnalyticsLogError(err) \
do { \
    if(err) \
        [[mAAnalytics instance] logError:err function:__PRETTY_FUNCTION__ line:__LINE__]; \
} while(0)

@interface mAAnalytics : NSObject

+ (instancetype)instance;
+ (BOOL)needsOptOutSelection;
+ (void)setOptOut:(BOOL)optOut;

- (void)logError:(NSError *)error
        function:(const char *)func
            line:(int)line;

// screens
- (void)editorScreen;
- (void)playerScreen;

// general
- (void)appLaunch;

// buttons
- (void)editButton;
- (void)playButton;
- (void)consoleButton;
- (void)shredsButton;
- (void)settingsButton;

- (void)myScripts;
- (void)recentScripts;
- (void)exampleScripts;
- (void)createNewScript;
- (void)createNewFolder;
- (void)editScriptList;
- (void)deleteFromScriptList:(NSString *)file;
- (void)moveSelectedItems;
- (void)deleteSelectedItems;
- (void)editFolderName;

- (void)editAddButton:(NSString *)file;
- (void)editReplaceButton:(NSString *)file;
- (void)editRemoveButton:(NSString *)file;
- (void)editEditScript:(NSString *)file;
- (void)editTitleButton:(NSString *)file;

- (void)playAddScript:(NSString *)file;
- (void)playAddButton:(NSString *)file;
- (void)playReplaceButton:(NSString *)file;
- (void)playRemoveButton:(NSString *)file;
- (void)playEditButton:(NSString *)file;
- (void)playDeleteButton:(NSString *)file;

@end
