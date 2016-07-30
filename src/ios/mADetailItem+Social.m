//
//  mADetailItem+Social.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/29/16.
//
//

#import "mADetailItem+Social.h"
#import "mADocumentManager.h"

#import "Patch.h"

#import <objc/runtime.h>

@implementation mADetailItem (Social)

- (void)setPatch:(Patch *)patch
{
    // add to metadata
    NSDictionary *patchDict = [patch asDictionary];
    [[mADocumentManager manager] setMetadata:@"SocialPatch" value:patchDict forItem:self];
    
    // cache
    // via http://nshipster.com/associated-objects/
    objc_setAssociatedObject(self, @selector(patch), patch, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (Patch *)patch
{
    // check cache
    Patch *_patch = objc_getAssociatedObject(self, @selector(patch));
    
    if(_patch == nil)
        // read from metadata
        // via http://nshipster.com/associated-objects/
        _patch = [[mADocumentManager manager] metadata:@"SocialPatch" forItem:self];
    
    return _patch;
}

@end
