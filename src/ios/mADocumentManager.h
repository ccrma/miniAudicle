//
//  mADocumentManager.h
//  miniAudicle
//
//  Created by Spencer Salazar on 7/11/14.
//
//

#import <Foundation/Foundation.h>

@class mADetailItem;

@interface mADocumentManager : NSObject

+ (id)manager;

- (NSMutableArray *)loadScripts;
- (NSMutableArray *)loadExamples;
- (void)saveScripts;
- (void)renameScript:(mADetailItem *)item to:(NSString *)title;
- (void)deleteScript:(mADetailItem *)item;

- (mADetailItem *)newScript:(NSString *)title;

@end
