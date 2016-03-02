//
//  mAAnalytics.h
//  miniAudicle
//
//  Created by Spencer Salazar on 2/28/16.
//
//

#import <Foundation/Foundation.h>

@interface mAAnalytics : NSObject

+ (instancetype)instance;
+ (BOOL)needsOptOutSelection;
+ (void)setOptOut:(BOOL)optOut;

// general
- (void)appLaunch;

// buttons
- (void)editButton;
- (void)playButton;
- (void)consoleButton;
- (void)shredsButton;

- (void)myScripts;
- (void)recentScripts;
- (void)exampleScripts;
- (void)createNewScript;
- (void)editScriptList;
- (void)deleteFromScriptList:(NSString *)file;

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
