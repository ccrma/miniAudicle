//
//  mADocumentManager.h
//  miniAudicle
//
//  Created by Spencer Salazar on 7/11/14.
//
//

#import <Foundation/Foundation.h>

@class mADetailItem;

extern NSString * const mADocumentManagerRecentFilesChanged;

@interface mADocumentManager : NSObject

@property (readonly) NSMutableArray *recentFiles;
@property (readonly) NSArray *userScripts;
@property (readonly) NSArray *exampleScripts;

+ (instancetype)manager;

- (void)saveScripts;
- (void)renameScript:(mADetailItem *)item to:(NSString *)title;
- (void)deleteScript:(mADetailItem *)item;

- (void)addRecentFile:(mADetailItem *)item;

- (mADetailItem *)newScript:(NSString *)title;
- (mADetailItem *)newScript;

@end
