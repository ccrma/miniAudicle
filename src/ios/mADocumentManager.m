//
//  mADocumentManager.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/11/14.
//
//

#import "mADocumentManager.h"
#import "mADetailItem.h"


static const int MAX_RECENT_ITEMS = 12;


@interface mADocumentManager ()
{
    NSMutableArray *_recentFiles;
}

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
        
        _recentFiles = [NSMutableArray new];
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
    
    return scripts;
}

- (NSMutableArray *)loadExamples
{
    NSMutableArray *examplesArray = [NSMutableArray array];
    
    [self appendScriptsFromDirectory:[self examplesPath]
                             toArray:examplesArray];
    
    return examplesArray;
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
    NSError *error = NULL;

    [item save];
    
    NSString *newPath = [[[item.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:title] stringByAppendingPathExtension:@"ck"];

    [[NSFileManager defaultManager] moveItemAtPath:item.path toPath:newPath error:&error];
    
    if(error != NULL)
    {
        NSLogFun(@"error: %@", error);
        return;
    }

    item.title = title;
    item.path = newPath;
}

- (void)deleteScript:(mADetailItem *)item
{
    NSError *error = NULL;

    [[NSFileManager defaultManager] removeItemAtPath:item.path
                                               error:&error];
    
    if(error != NULL)
    {
        NSLogFun(@"error: %@", error);
    }
}

- (void)addRecentFile:(mADetailItem *)item
{
    // should probably use NSSet but it would involve a complicated refactor    
    if([_recentFiles containsObject:item])
        [_recentFiles removeObject:item];
    
    [_recentFiles insertObject:item atIndex:0];
    while([_recentFiles count] > MAX_RECENT_ITEMS)
    {
        [_recentFiles removeObjectAtIndex:[_recentFiles count]-1];
    }
}

@end
