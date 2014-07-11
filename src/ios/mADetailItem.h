//
//  mADetailItem.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/27/14.
//
//

#import <Foundation/Foundation.h>

#import "chuck_def.h"

@interface mADetailItem : NSObject

@property (nonatomic) BOOL isUser;
@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * text;
@property (nonatomic) t_CKUINT docid;
@property (nonatomic) BOOL isFolder;
@property (strong, nonatomic) NSMutableArray *folderItems;
@property (strong, nonatomic) NSString *path;

+ (mADetailItem *)detailItemFromPath:(NSString *)path isUser:(BOOL)isUser;
+ (mADetailItem *)detailItemFromDictionary:(NSDictionary *)dictionary;
+ (mADetailItem *)folderDetailItemWithTitle:(NSString *)title
                                      items:(NSMutableArray *)items
                                     isUser:(BOOL)user;
- (NSDictionary *)dictionary;
- (void)save;

@end

