//
//  Patch.m
//  chuckpad-social-ios
//
//  Created by Mark Cerqueira on 6/17/16.
//
//

#import <Foundation/Foundation.h>
#import "Patch.h"

@implementation Patch {

    @private
    NSInteger _patchId;
    BOOL _isFeatured;
    BOOL _isDocumentation;
    NSString *_contentType;
    NSString *_resourceUrl;
    NSString *_filename;
}

@synthesize patchId = _patchId;
@synthesize isFeatured = _isFeatured;
@synthesize isDocumentation = _isDocumentation;
@synthesize contentType = _contentType;
@synthesize resourceUrl = _resourceUrl;
@synthesize filename = _filename;

- (Patch *)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.patchId = [dictionary[@"id"] integerValue];
        self.name = dictionary[@"name"];
        self.isFeatured = [dictionary[@"featured"] boolValue];
        self.isDocumentation = [dictionary[@"documentation"] boolValue];
        self.contentType = dictionary[@"content_type"];
        self.resourceUrl = dictionary[@"resource"];
        self.filename = dictionary[@"filename"];

    }

    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"patchId = %ld; name = %@; documentation = %d, featured = %d", (long)self.patchId, self.name, self.isDocumentation, self.isFeatured];
}


@end
