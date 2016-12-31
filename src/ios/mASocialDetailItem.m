//
//  mASocialDetailItem.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/26/16.
//
//

#import "mASocialDetailItem.h"
#import "mAAnalytics.h"

#import "ChuckPadSocial.h"
#import "Patch.h"


@interface mASocialDetailItem ()

@end


@implementation mASocialDetailItem

+ (mASocialDetailItem *)socialDetailItemWithPatch:(Patch *)patch
{
    mASocialDetailItem *item = [mASocialDetailItem new];
    item.patch = patch;
    item.isUser = NO;
    
    item.title = patch.name;
    item.text = nil;
    item.type = DETAILITEM_CHUCK_SCRIPT;
    
    return item;
}

- (BOOL)isSocial
{
    return YES;
}

- (BOOL)isLoaded
{
    return NO;
}

- (BOOL)isMyPatch
{
    return self.patch.creatorId == [[ChuckPadSocial sharedInstance] getLoggedInUserId];
}

- (void)load:(void (^)(BOOL success, NSError *error))callback
{
    [[ChuckPadSocial sharedInstance] downloadPatchResource:self.patch callback:^(NSData *data, NSError *error) {
        if (data != nil && error == nil)
        {
            self.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            callback(YES, nil);
        }
        else
        {
            mAAnalyticsLogError(error);
            callback(NO, error);
        }
    }];
}

- (void)save
{
    // 
}

@end
