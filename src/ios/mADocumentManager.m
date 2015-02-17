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
NSString * const mADocumentManagerRecentFilesChanged = @"mADocumentManagerRecentFilesChanged";

NSString * const mAPreferencesRecentFilesKey = @"mAPreferencesRecentFilesKey";


@interface NSString (mADocumentManager)

- (NSString *)stripDocumentPath;
- (BOOL)matchesDocumentPath:(NSString *)documentPath;

@end


@interface mADocumentManager ()
{
    NSMutableArray *_userScripts;
    NSMutableArray *_exampleScripts;
    
    NSMutableArray *_recentFiles;
    NSMutableOrderedSet *_recentFilesPaths;
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
        _recentFilesPaths = [NSMutableOrderedSet orderedSetWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesRecentFilesKey]];
        
        [self loadScripts];
        [self loadExamples];
        
        [_recentFiles sortUsingComparator:^NSComparisonResult(mADetailItem *obj1, mADetailItem *obj2) {
            int index1 = [_recentFilesPaths indexOfObject:[[obj1 path] stripDocumentPath]];
            int index2 = [_recentFilesPaths indexOfObject:[[obj2 path] stripDocumentPath]];
            
            if(index1 < index2) return NSOrderedAscending;
            if(index1 > index2) return NSOrderedDescending;
            return NSOrderedSame;
        }];
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
            // TODO: load lazily
            detailItem.text = [NSString stringWithContentsOfFile:fullPath
                                                        encoding:NSUTF8StringEncoding error:NULL];
            detailItem.isFolder = NO;
            detailItem.folderItems = nil;
            detailItem.path = fullPath;
            
            [array addObject:detailItem];
            
            if([_recentFilesPaths containsObject:[fullPath stripDocumentPath]])
                [_recentFiles addObject:detailItem];
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
    if(_userScripts == nil)
    {
        _userScripts = [NSMutableArray array];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *path = [self.baseDocumentPath path];
        for(NSString *subpath in [fileManager contentsOfDirectoryAtPath:path error:NULL])
        {
            NSString *fullPath = [path stringByAppendingPathComponent:subpath];
            mADetailItem *item = [mADetailItem detailItemFromPath:fullPath isUser:YES];
            [_userScripts addObject:item];
            
            if([_recentFilesPaths containsObject:[fullPath stripDocumentPath]])
                [_recentFiles addObject:item];
        }
    }
    
    return _userScripts;
}

- (NSMutableArray *)loadExamples
{
    if(_exampleScripts == nil)
    {
        _exampleScripts = [NSMutableArray array];
        
        [self appendScriptsFromDirectory:[self examplesPath]
                                 toArray:_exampleScripts];
    }
    
    return _exampleScripts;
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
    
    // ensure only one copy in the array
    NSString *documentPath = [item.path stripDocumentPath];
    if([_recentFiles containsObject:item])
        [_recentFiles removeObject:item];
    if([_recentFilesPaths containsObject:documentPath])
        [_recentFilesPaths removeObject:documentPath];
    
    // insert at beginning
    [_recentFiles insertObject:item atIndex:0];
    [_recentFilesPaths insertObject:documentPath atIndex:0];
    
    // maintain max
    while([_recentFiles count] > MAX_RECENT_ITEMS)
        [_recentFiles removeLastObject];
    while([_recentFilesPaths count] > MAX_RECENT_ITEMS)
        [_recentFilesPaths removeObjectAtIndex:[_recentFilesPaths count]-1];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:mADocumentManagerRecentFilesChanged object:self];
    
    [[NSUserDefaults standardUserDefaults] setObject:[_recentFilesPaths array] forKey:mAPreferencesRecentFilesKey];
}

@end


@implementation NSString (mADocumentManager)

- (NSString *)stripDocumentPath
{
    NSRange range = [self rangeOfString:@"examples"];
    if(range.location != NSNotFound) return [self substringFromIndex:range.location];
    
    range = [self rangeOfString:@"Documents"];
    if(range.location != NSNotFound) return [self substringFromIndex:range.location];
    
    return nil;
}

- (BOOL)matchesDocumentPath:(NSString *)documentPath
{
    NSRange range = [self rangeOfString:documentPath options:NSBackwardsSearch];
    // only if it matches at the very end of the string
    if(range.location != NSNotFound && NSMaxRange(range) == [self length])
        return YES;
    return NO;
}

@end



