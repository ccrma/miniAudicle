//
//  mASocialDetailItem.h
//  miniAudicle
//
//  Created by Spencer Salazar on 7/26/16.
//
//

#import "mADetailItem.h"

@class Patch;

@interface mASocialDetailItem : mADetailItem

@property (strong) Patch *patch;

+ (mASocialDetailItem *)socialDetailItemWithPatch:(Patch *)patch;

- (BOOL)isLoaded;
- (BOOL)isMyPatch;
- (void)load:(void (^)(BOOL success, NSError *error))callback;

@end
