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

- (id)init;

// general
- (void)appLaunch;

// buttons
- (void)editButton;
- (void)playButton;
- (void)consoleButton;
- (void)shredsButton;

- (void)editAddButton:(NSString *)file;
- (void)editReplaceButton:(NSString *)file;
- (void)editRemoveButton:(NSString *)file;
- (void)editEditAction:(NSString *)file;

- (void)playAddButton:(NSString *)file;
- (void)playReplaceButton:(NSString *)file;
- (void)playRemoveButton:(NSString *)file;

@end
