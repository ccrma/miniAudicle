//
//  mADocumentationController.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/5/15.
//
//

#import "mADocumentationController.h"

@interface mADocumentationController ()

+ (NSString *)documentationDirectory;
+ (NSString *)singlePageDocDirectory;

@end

@implementation mADocumentationController

+ (id)instance
{
    mADocumentationController *s_instance = nil;
    
    if(s_instance == nil)
        s_instance = [mADocumentationController new];
    return s_instance;
}

+ (NSString *)documentationDirectory
{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"doc"];
}

+ (NSString *)singlePageDocDirectory
{
    return [[self documentationDirectory] stringByAppendingPathComponent:@"single"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (BOOL)hasDocumentationForTypeName:(NSString *)typeName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docPath = [[[self class] singlePageDocDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.html", typeName]];
    
    if([fileManager fileExistsAtPath:docPath])
    {
        // displayName should be case-normalized
        // so we can identify 'SinOsc' but not 'sinosc'
        NSString *displayName = [fileManager displayNameAtPath:docPath];
        if([[[displayName lastPathComponent] stringByDeletingPathExtension] isEqualToString:typeName])
            return YES;
    }
    
    return NO;
}

@end
