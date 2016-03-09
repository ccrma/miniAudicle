//
//  mADocumentManager.h
//  miniAudicle
//
//  Created by Spencer Salazar on 7/11/14.
//
//

#import <Foundation/Foundation.h>
#import "KVOMutableArray.h"

@class mADetailItem;

extern NSString * const mADocumentManagerRecentFilesChanged;

@interface mADocumentManager : NSObject

@property (readonly) KVOMutableArray *recentFiles;
@property (readonly) KVOMutableArray *userScripts;
@property (readonly) NSArray *exampleScripts;

+ (instancetype)manager;

- (void)saveScripts;
- (void)renameScript:(mADetailItem *)item to:(NSString *)title;
- (void)deleteScript:(mADetailItem *)item;

- (void)addRecentFile:(mADetailItem *)item;

- (mADetailItem *)newScript:(NSString *)title;
- (mADetailItem *)newScript;
- (mADetailItem *)newItemFromURL:(NSURL *)url;

@end
