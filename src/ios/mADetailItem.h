//
//  mADetailItem.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/27/14.
//
//

#import <Foundation/Foundation.h>

#import "chuck_def.h"

@class mANANewScript;

@interface mADetailItem : NSObject

@property (nonatomic) BOOL isUser;
@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * text;
@property (nonatomic) t_CKUINT docid;
@property (nonatomic) BOOL isFolder;
@property (strong, nonatomic) NSMutableArray *folderItems;
@property (strong, nonatomic) NSString *path;
@property (nonatomic) t_CKUINT numShreds;

@property (nonatomic) BOOL remote;
@property (copy, nonatomic) NSString *remoteUUID;
@property (copy, nonatomic) NSString *remoteUsername;
@property (nonatomic) BOOL hasLocalEdits;

+ (mADetailItem *)detailItemFromPath:(NSString *)path isUser:(BOOL)isUser;
+ (mADetailItem *)folderDetailItemWithTitle:(NSString *)title
                                      items:(NSMutableArray *)items
                                     isUser:(BOOL)user;
+ (mADetailItem *)remoteDetailItemWithNewScriptAction:(mANANewScript *)action;

- (NSDictionary *)dictionary;
- (void)save;

@end

