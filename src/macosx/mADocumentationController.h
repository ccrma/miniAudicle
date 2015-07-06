//
//  mADocumentationController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 7/5/15.
//
//

#import <Cocoa/Cocoa.h>

@class miniAudicleController;

@interface mADocumentationController : NSViewController

@property (nonatomic, retain) miniAudicleController *mAController;

+ (id)instance;

- (BOOL)hasDocumentationForTypeName:(NSString *)typeName;

@end
