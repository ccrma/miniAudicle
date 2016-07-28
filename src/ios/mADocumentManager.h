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

@property (readonly) mADetailItem *recentFilesFolderItem;
@property (readonly) mADetailItem *userScriptsFolderItem;
@property (readonly) mADetailItem *exampleScriptsFolderItem;

+ (instancetype)manager;

- (void)saveScripts;
- (BOOL)renameItem:(mADetailItem *)item to:(NSString *)title error:(NSError **)error;
// TODO: handle re-parenting in mADetailItem structure
- (BOOL)moveItem:(mADetailItem *)item toDirectory:(mADetailItem *)dir error:(NSError **)error;
// TODO: handle de-parenting in mADetailItem structure
- (void)deleteItem:(mADetailItem *)item;

- (mADetailItem *)firstUserScript;

- (void)addRecentFile:(mADetailItem *)item;

- (mADetailItem *)newScript:(NSString *)title;
- (mADetailItem *)newScriptUnderParent:(mADetailItem *)parent;
- (mADetailItem *)newFolderUnderParent:(mADetailItem *)parent;
- (mADetailItem *)newItemFromURL:(NSURL *)url;

- (void)setMetadata:(NSString *)key key:(id)value forItem:(mADetailItem *)item;
- (id)metadata:(NSString *)key forItem:(mADetailItem *)item;

@end
