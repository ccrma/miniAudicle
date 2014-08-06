//
//  mADocumentManager.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/11/14.
//
//

#import "mADocumentManager.h"
#import "mADetailItem.h"


@interface mADocumentManager ()

@property (strong, nonatomic) id<NSObject, NSCopying, NSCoding> ubiquityIdentityToken;
@property (copy, nonatomic) NSURL *baseDocumentPath;

@end


@implementation mADocumentManager

+ (id)manager
{
    static mADocumentManager *s_manager = nil;
    
    if(s_manager == nil) s_manager = [mADocumentManager new];
        
    return s_manager;
}

- (id)init
{
    if(self = [super init])
    {
        self.ubiquityIdentityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
        
        if(self.ubiquityIdentityToken)
        {
            self.baseDocumentPath = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
        }
        else
        {
            self.baseDocumentPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        }
    }
    
    return self;
}

- (NSString *)examplesPath
{
    return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"examples"];
}

- (void)appendScriptsFromDirectory:(NSString *)dir toArray:(NSMutableArray *)array
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for(NSString *path in [fileManager contentsOfDirectoryAtPath:dir error:NULL])
    {
        BOOL isDirectory = NO;
        NSString *fullPath = [dir stringByAppendingPathComponent:path];
        
        if([[path pathExtension] isEqualToString:@"ck"])
        {
            mADetailItem *detailItem = [mADetailItem new];
            detailItem.isUser = NO;
            detailItem.title = path;
            detailItem.text = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:NULL];
            detailItem.isFolder = NO;
            detailItem.folderItems = nil;
            detailItem.path = fullPath;
            
            [array addObject:detailItem];
        }
        else if([fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory] && isDirectory)
        {
            mADetailItem *detailItem = [mADetailItem new];
            detailItem.isUser = NO;
            detailItem.title = path;
            detailItem.text = @"";
            detailItem.isFolder = YES;
            detailItem.folderItems = [NSMutableArray array];
            
            [self appendScriptsFromDirectory:fullPath toArray:detailItem.folderItems];
            
            [array addObject:detailItem];
        }
    }
}

- (NSMutableArray *)loadScripts
{
    NSMutableArray * scripts = [NSMutableArray array];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self.baseDocumentPath path];
    for(NSString *subpath in [fileManager contentsOfDirectoryAtPath:path error:NULL])
        [scripts addObject:[mADetailItem detailItemFromPath:[path stringByAppendingPathComponent:subpath]
                                                     isUser:YES]];
    
    NSMutableArray *examplesArray = [NSMutableArray array];
    
    [self appendScriptsFromDirectory:[self examplesPath]
                             toArray:examplesArray];
    
    [scripts addObject:[mADetailItem folderDetailItemWithTitle:@"Examples"
                                                         items:examplesArray
                                                        isUser:NO]];
    
    return scripts;
}

- (void)saveScripts
{
    
}

- (mADetailItem *)newScript:(NSString *)title
{
    mADetailItem * detailItem = [mADetailItem new];
    
    detailItem.isUser = YES;
    detailItem.title = title;
    detailItem.path = [[[self.baseDocumentPath URLByAppendingPathComponent:detailItem.title] URLByAppendingPathExtension:@"ck"] path];
    detailItem.text = @"";
    
    return detailItem;
}

- (void)renameScript:(mADetailItem *)item to:(NSString *)title
{
    NSString *newPath = [[[self.baseDocumentPath URLByAppendingPathComponent:title] URLByAppendingPathExtension:@"ck"] path];

    [[NSFileManager defaultManager] moveItemAtPath:item.path toPath:newPath error:NULL];
    
    item.title = title;
    item.path = newPath;
}

@end
