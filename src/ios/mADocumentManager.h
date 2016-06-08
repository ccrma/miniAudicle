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

//@property (readonly) KVOMutableArray *recentFiles;
//@property (readonly) KVOMutableArray *userScripts;
//@property (readonly) NSArray *exampleScripts;

@property (readonly) mADetailItem *recentFilesFolderItem;
@property (readonly) mADetailItem *userScriptsFolderItem;
@property (readonly) mADetailItem *exampleScriptsFolderItem;

+ (instancetype)manager;

- (void)saveScripts;
- (BOOL)renameItem:(mADetailItem *)item to:(NSString *)title error:(NSError **)error;
- (BOOL)moveItem:(mADetailItem *)item toDirectory:(mADetailItem *)dir error:(NSError **)error;
- (void)deleteItem:(mADetailItem *)item;

- (mADetailItem *)firstUserScript;

- (void)addRecentFile:(mADetailItem *)item;

- (mADetailItem *)newScript:(NSString *)title;
- (mADetailItem *)newScriptUnderParent:(mADetailItem *)parent;
- (mADetailItem *)newFolderUnderParent:(mADetailItem *)parent;
- (mADetailItem *)newItemFromURL:(NSURL *)url;

@end
