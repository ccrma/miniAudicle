//
//  mADocumentManager.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/11/14.
//
//

#import "mADocumentManager.h"
#import "mADetailItem.h"
#import "mAAnalytics.h"


static const int MAX_RECENT_ITEMS = 12;
NSString * const mADocumentManagerRecentFilesChanged = @"mADocumentManagerRecentFilesChanged";

NSString * const mAPreferencesRecentFilesKey = @"mAPreferencesRecentFilesKey";


@interface NSString (mADocumentManager)

- (BOOL)hasPathExtension:(NSArray *)extensions;
- (NSString *)stripDocumentPath;
- (BOOL)matchesDocumentPath:(NSString *)documentPath;

@end


@interface mADocumentManager ()
{
    NSMutableArray *_userScripts;
    NSMutableArray *_exampleScripts;
    
    NSMutableArray *_recentFiles;
    NSMutableOrderedSet *_recentFilesPaths;
    
    int _untitledNum;
}

@property (strong, nonatomic) id<NSObject, NSCopying, NSCoding> ubiquityIdentityToken;
@property (copy, nonatomic) NSURL *iCloudDocumentPath;
@property (copy, nonatomic) NSURL *localDocumentPath;

+ (NSArray *)documentExtensions;
+ (NSArray *)audioFileExtensions;

- (NSMutableArray *)loadScripts;
- (NSMutableArray *)loadExamples;
- (void)_uniqueTitleAndPathForTitle:(NSString *)title
                              title:(NSString **)newTitle
                               path:(NSString **)path;

@end


@implementation mADocumentManager

+ (NSArray *)documentExtensions
{
    return @[@"ck", @"wav", @"aif", @"aiff"];
}

+ (NSArray *)audioFileExtensions
{
    return @[@"wav", @"aif", @"aiff"];
}

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
        self.localDocumentPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        
        self.ubiquityIdentityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
        
        if(self.ubiquityIdentityToken)
        {
            self.iCloudDocumentPath = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
        }
        
        _untitledNum = 1;
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

- (void)appendScriptsFromDirectory:(NSString *)dir
                           toArray:(NSMutableArray *)array
                            isUser:(BOOL)isUser
                            filter:(BOOL (^)(NSString *fullPath))filter
                         processor:(void (^)(mADetailItem *))processor
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    for(NSString *path in [fileManager contentsOfDirectoryAtPath:dir error:NULL])
    {
        BOOL isDirectory = NO;
        NSString *fullPath = [dir stringByAppendingPathComponent:path];
        
        if(filter && filter(fullPath))
            continue;
        
        if([path hasPathExtension:[mADocumentManager documentExtensions]])
        {
            mADetailItem *detailItem = [mADetailItem detailItemFromPath:fullPath isUser:isUser];
            
            [array addObject:detailItem];
            
            if([_recentFilesPaths containsObject:[fullPath stripDocumentPath]])
                [_recentFiles addObject:detailItem];
            
            if(processor)
                processor(detailItem);
        }
        else if([fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory] && isDirectory)
        {
            mADetailItem *detailItem = [mADetailItem new];
            detailItem.isUser = NO;
            detailItem.title = path;
            detailItem.text = @"";
            detailItem.isFolder = YES;
            detailItem.folderItems = [NSMutableArray array];
            detailItem.type = DETAILITEM_DIRECTORY;
            
            if(processor)
                processor(detailItem);
            
            [self appendScriptsFromDirectory:fullPath
                                     toArray:detailItem.folderItems
                                      isUser:isUser
                                      filter:filter
                                   processor:processor];
            
            [array addObject:detailItem];
        }
    }
}

- (NSMutableArray *)loadScripts
{
    if(_userScripts == nil)
    {
        _userScripts = [NSMutableArray array];
        
        if(self.iCloudDocumentPath)
        {
            [self appendScriptsFromDirectory:[self.iCloudDocumentPath path]
                                     toArray:_userScripts
                                      isUser:YES
                                      filter:nil
                                   processor:^(mADetailItem *detailItem) {
                                       // use greatest untitledN number +1 for next Untitled number
                                       NSScanner *titleScanner = [NSScanner scannerWithString:detailItem.title];
                                       int num = 0;
                                       if([titleScanner scanString:@"untitled" intoString:NULL] &&
                                          [titleScanner scanInt:&num])
                                       {
                                           if(num >= _untitledNum)
                                               _untitledNum = num+1;
                                       }
                                   }];
        }
        
        [self appendScriptsFromDirectory:[self.localDocumentPath path]
                                 toArray:_userScripts
                                  isUser:YES
                                  filter:^BOOL (NSString *fullPath){
                                      if([[fullPath stripDocumentPath] isEqualToString:@"Inbox"])
                                          return YES;
                                      return NO;
                                  }
                               processor:^(mADetailItem *detailItem) {
                                   // use greatest untitledN number +1 for next Untitled number
                                   NSScanner *titleScanner = [NSScanner scannerWithString:detailItem.title];
                                   int num = 0;
                                   if([titleScanner scanString:@"untitled" intoString:NULL] &&
                                      [titleScanner scanInt:&num])
                                   {
                                       if(num >= _untitledNum)
                                           _untitledNum = num+1;
                                   }
                               }];
        
        [_userScripts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            mADetailItem *item1 = obj1;
            mADetailItem *item2 = obj2;
            return [item1.title compare:item2.title];
        }];
    }
    
    return _userScripts;
}

- (NSMutableArray *)loadExamples
{
    if(_exampleScripts == nil)
    {
        _exampleScripts = [NSMutableArray array];
        
        [self appendScriptsFromDirectory:[self examplesPath]
                                 toArray:_exampleScripts
                                  isUser:NO
                                  filter:NULL
                               processor:NULL];
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
    detailItem.path = [[[self.iCloudDocumentPath URLByAppendingPathComponent:detailItem.title] URLByAppendingPathExtension:@"ck"] path];
    detailItem.text = @"";
    
    return detailItem;
}

- (mADetailItem *)newScript
{
    NSString *title = [NSString stringWithFormat:@"untitled%i.ck", _untitledNum++];
    
    mADetailItem * detailItem = [mADetailItem new];
    
    detailItem.isUser = YES;
    detailItem.title = title;
    if(self.iCloudDocumentPath)
        detailItem.path = [[self.iCloudDocumentPath URLByAppendingPathComponent:detailItem.title] path];
    else
        detailItem.path = [[self.localDocumentPath URLByAppendingPathComponent:detailItem.title] path];
    detailItem.text = @"";
    detailItem.type = DETAILITEM_CHUCK_SCRIPT;
    
    [_userScripts addObject:detailItem];
    
    return detailItem;
}

- (mADetailItem *)newItemFromURL:(NSURL *)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    
    NSString *urlString = [url path];
    NSString *title = [[urlString pathComponents] lastObject];
    NSString *path;
    
    [self _uniqueTitleAndPathForTitle:title title:&title path:&path];
    
    [fileManager copyItemAtURL:url toURL:[NSURL fileURLWithPath:path] error:&error];
    mAAnalyticsLogError(error);

    mADetailItem * detailItem = [mADetailItem new];
    
    NSString *ext = [urlString pathExtension];
    
    detailItem.isUser = YES;
    detailItem.title = title;
    detailItem.path = path;
    
    if([ext isEqualToString:@"ck"])
    {
        detailItem.type = DETAILITEM_CHUCK_SCRIPT;
        detailItem.text = [NSString stringWithContentsOfURL:url
                                                   encoding:NSUTF8StringEncoding
                                                      error:&error];
        mAAnalyticsLogError(error);
    }
    else if([ext hasPathExtension:[mADocumentManager audioFileExtensions]])
    {
        detailItem.type = DETAILITEM_AUDIO_FILE;
    }
    else
    {
        detailItem.type = DETAILITEM_MISC;
    }
    
    [_userScripts addObject:detailItem];
        
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

- (void)_uniqueTitleAndPathForTitle:(NSString *)title
                              title:(NSString **)_newTitle
                               path:(NSString **)_path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *documentPath;
    
    if(self.iCloudDocumentPath)
        documentPath = self.iCloudDocumentPath;
    else
        documentPath = self.localDocumentPath;
    
    NSString *path = [[documentPath URLByAppendingPathComponent:title] path];
    
    if([fileManager fileExistsAtPath:path])
    {
        int fileNo = 1;
        
        NSString *base = [title stringByDeletingPathExtension];
        NSString *ext = [title pathExtension];
        char lastBaseChar = [base characterAtIndex:[base length]-1];
        
        while([fileManager fileExistsAtPath:path])
        {
            NSString *fileNoSuffix;
            if(isdigit(lastBaseChar))
                fileNoSuffix = [NSString stringWithFormat:@"-%i", fileNo];
            else
                fileNoSuffix = [NSString stringWithFormat:@"%i", fileNo];
            
            if(ext)
                title = [NSString stringWithFormat:@"%@%@.%@", base, fileNoSuffix, ext];
            else
                title = [NSString stringWithFormat:@"%@%@", base, fileNoSuffix];
            
            path = [[documentPath URLByAppendingPathComponent:title] path];
            fileNo++;
            
            assert(fileNo < 100);
        }
    }
    
    if(_newTitle)
        *_newTitle = title;
    if(_path)
        *_path = path;
}


@end


@implementation NSString (mADocumentManager)

- (BOOL)hasPathExtension:(NSArray *)extensions
{
    NSString *myExt = [self pathExtension];
    for(NSString *ext in extensions)
    {
        if([myExt isEqualToString:ext])
            return YES;
    }
    
    return NO;
}

- (NSString *)stripDocumentPath
{
    NSRange range = [self rangeOfString:@"examples/"];
    if(range.location != NSNotFound) return [self substringFromIndex:range.location+range.length];
    
    range = [self rangeOfString:@"Documents/"];
    if(range.location != NSNotFound) return [self substringFromIndex:range.location+range.length];
    
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



