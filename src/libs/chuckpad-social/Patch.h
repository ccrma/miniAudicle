//
//  Patch.h
//  chuckpad-social-ios
//
//  Created by Mark Cerqueira on 6/17/16.
//
//

#ifndef Patch_h
#define Patch_h

@interface Patch : NSObject

@property(nonatomic, retain) NSString *name;
@property(nonatomic, assign) NSInteger patchId;
@property(nonatomic, assign) BOOL isFeatured;
@property(nonatomic, assign) BOOL isDocumentation;
@property(nonatomic, retain) NSString *filename;
@property(nonatomic, retain) NSString *contentType;
@property(nonatomic, retain) NSString *resourceUrl;

- (Patch *)initWithDictionary:(NSDictionary *)dictionary;

- (NSString *)description;

@end


#endif /* Patch_h */
