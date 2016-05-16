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

static NSString * const mAUntitledScriptName = @"untitled";
static NSString * const mAUntitledFolderName = @"untitled folder";


@interface NSString (mADocumentManager)

- (BOOL)hasPathExtension:(NSArray *)extensions;
- (NSString *)stripPath:(NSString *)path;
- (BOOL)matchesDocumentPath:(NSString *)documentPath;

@end


@interface mADocumentManager ()
{
    KVOMutableArray *_userScripts;
    NSMutableArray *_exampleScripts;
    
    KVOMutableArray *_recentFiles;
    // the paths are what is serialized
    // cache this structure as it is serialized every time the user opens a file
    NSMutableOrderedSet *_recentFilesPaths;
    
    int _untitledNum;
    int _untitledFolderNum;
}

@property (strong, nonatomic) id<NSObject, NSCopying, NSCoding> ubiquityIdentityToken;
@property (copy, nonatomic) NSURL *iCloudDocumentPath;
@property (copy, nonatomic) NSURL *localDocumentPath;

+ (NSArray *)documentExtensions;
+ (NSArray *)audioFileExtensions;

- (NSURL *)defaultDocumentPath;
- (NSString *)examplesPath;
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

- (NSURL *)defaultDocumentPath
{
    return self.localDocumentPath;
}

- (id)init
{
    if(self = [super init])
    {
        self.localDocumentPath = [NSURL fileURLWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]];
        
        // disable iCloud for now
//        self.ubiquityIdentityToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
//        
//        if(self.ubiquityIdentityToken)
//        {
//            self.iCloudDocumentPath = [[[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil] URLByAppendingPathComponent:@"Documents"];
//        }
        
        _untitledNum = 1;
        _untitledFolderNum = 1;
        _recentFiles = [KVOMutableArray new];
        _recentFilesPaths = [NSMutableOrderedSet orderedSetWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:mAPreferencesRecentFilesKey]];
        
        [self loadScripts];
        [self loadExamples];
        
        [_recentFiles sortUsingComparator:^NSComparisonResult(mADetailItem *obj1, mADetailItem *obj2) {
            int index1 = [_recentFilesPaths indexOfObject:[obj1 path]];
            int index2 = [_recentFilesPaths indexOfObject:[obj2 path]];
            
            if(index1 < index2) return NSOrderedAscending;
            if(index1 > index2) return NSOrderedDescending;
            return NSOrderedSame;
        }];
        
        _userScriptsFolderItem = [mADetailItem folderDetailItemWithTitle:@"Scripts"
                                                                   items:_userScripts
                                                                  isUser:YES];
        _userScriptsFolderItem.path = [self.defaultDocumentPath path];
        
        _recentFilesFolderItem = [mADetailItem folderDetailItemWithTitle:@"Recent"
                                                                   items:_recentFiles
                                                                  isUser:YES];
        _exampleScriptsFolderItem = [mADetailItem folderDetailItemWithTitle:@"Examples"
                                                                      items:_exampleScripts
                                                                     isUser:YES];
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
            
            if([_recentFilesPaths containsObject:fullPath])
                [_recentFiles addObject:detailItem];
            
            if(processor)
                processor(detailItem);
        }
        else if([fileManager fileExistsAtPath:fullPath isDirectory:&isDirectory] && isDirectory)
        {
            mADetailItem *detailItem = [mADetailItem new];
            detailItem.isUser = isUser;
            detailItem.title = path;
            detailItem.type = DETAILITEM_DIRECTORY;
            detailItem.folderItems = [KVOMutableArray array];
            detailItem.path = fullPath;
            
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
        _userScripts = [KVOMutableArray new];
        
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
                                       if([titleScanner scanString:mAUntitledScriptName intoString:NULL] &&
                                          [titleScanner scanInt:&num])
                                       {
                                           if(num >= _untitledNum)
                                               _untitledNum = num+1;
                                       }
                                       
                                       // reset scanner
                                       titleScanner.scanLocation = 0;
                                       if([titleScanner scanString:mAUntitledFolderName intoString:NULL] &&
                                          [titleScanner scanInt:&num])
                                       {
                                           if(num >= _untitledFolderNum)
                                               _untitledFolderNum = num+1;
                                       }
                                   }];
        }
        
        [self appendScriptsFromDirectory:[self.localDocumentPath path]
                                 toArray:_userScripts
                                  isUser:YES
                                  filter:^BOOL (NSString *fullPath){
                                      if([[fullPath stripPath:[self.localDocumentPath path]] isEqualToString:@"Inbox"])
                                          return YES;
                                      return NO;
                                  }
                               processor:^(mADetailItem *detailItem) {
                                   // use greatest untitledN number +1 for next Untitled number
                                   NSScanner *titleScanner = [NSScanner scannerWithString:detailItem.title];
                                   int num = 0;
                                   if([titleScanner scanString:mAUntitledScriptName intoString:NULL] &&
                                      [titleScanner scanInt:&num])
                                   {
                                       if(num >= _untitledNum)
                                           _untitledNum = num+1;
                                   }
                                   
                                   // reset scanner
                                   titleScanner.scanLocation = 0;
                                   if([titleScanner scanString:mAUntitledFolderName intoString:NULL] &&
                                      [titleScanner scanInt:&num])
                                   {
                                       if(num >= _untitledFolderNum)
                                           _untitledFolderNum = num+1;
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

- (mADetailItem *)newFolderUnderParent:(mADetailItem *)parent
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *title;
    NSString *path;
    do {
        if(_untitledFolderNum > 1)
            title = [NSString stringWithFormat:@"%@ %i", mAUntitledFolderName, _untitledFolderNum++];
        else
            title = mAUntitledFolderName;
        path = [parent.path stringByAppendingPathComponent:title];
    } while([fileManager fileExistsAtPath:title]);

    NSError *error;
    [fileManager createDirectoryAtPath:path
           withIntermediateDirectories:NO attributes:nil error:&error];
    
    if(error != nil)
    {
        mAAnalyticsLogError(error);
        return nil;
    }
    
    mADetailItem * detailItem = [mADetailItem folderDetailItemWithTitle:title
                                                                  items:[KVOMutableArray array]
                                                                 isUser:YES];
    
    detailItem.path = path;
    [parent.folderItems addObject:detailItem];
    
    return detailItem;
}

- (mADetailItem *)newScriptUnderParent:(mADetailItem *)parent
{
    NSString *title = [NSString stringWithFormat:@"%@%i.ck", mAUntitledScriptName, _untitledNum++];
    
    mADetailItem * detailItem = [mADetailItem new];
    
    detailItem.isUser = YES;
    detailItem.title = title;
    detailItem.path = [parent.path stringByAppendingPathComponent:detailItem.title];
    detailItem.text = @"";
    detailItem.type = DETAILITEM_CHUCK_SCRIPT;
    
    [parent.folderItems addObject:detailItem];
    
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
    
    detailItem.isUser = YES;
    detailItem.title = title;
    detailItem.path = path;
    
    if([detailItem.path hasPathExtension:@[@"ck"]])
    {
        detailItem.type = DETAILITEM_CHUCK_SCRIPT;
    }
    else if([detailItem.path hasPathExtension:[mADocumentManager audioFileExtensions]])
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

- (void)renameItem:(mADetailItem *)item to:(NSString *)title
{
    NSError *error = NULL;

    [item save];
    
    NSString *extension = [item.path pathExtension];
    NSString *newPath = [[item.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:title];
    if([extension length])
        newPath = [newPath stringByAppendingString:extension];

    [[NSFileManager defaultManager] moveItemAtPath:item.path toPath:newPath error:&error];
    
    if(error != NULL)
    {
        mAAnalyticsLogError(error);
        return;
    }

    item.title = title;
    item.path = newPath;
}

- (void)deleteItem:(mADetailItem *)item
{
    NSError *error = NULL;

    [[NSFileManager defaultManager] removeItemAtPath:item.path
                                               error:&error];
    
    if(error != NULL)
    {
        NSLogFun(@"error: %@", error);
    }
}

- (mADetailItem *)firstUserScript
{
    mADetailItem *userScript = nil;
    
    for(mADetailItem *script in _userScripts)
    {
        if(!script.isFolder)
        {
            userScript = script;
            break;
        }
    }
    
    return userScript;
}

- (void)addRecentFile:(mADetailItem *)item
{
    // should probably use NSSet but it would involve a complicated refactor
    
    // ensure only one copy in the array
    NSString *documentPath = item.path;
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

- (NSString *)stripBundlePath
{
    NSString *path = [[NSBundle mainBundle] resourcePath];
    NSRange range = [self rangeOfString:path];
    if(range.location != NSNotFound) return [self substringFromIndex:range.location+range.length];
    
    return nil;
}

- (NSString *)stripDocumentPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSRange range = [self rangeOfString:path];
    if(range.location != NSNotFound) return [self substringFromIndex:range.location+range.length];
    
    return nil;
}

- (NSString *)stripPath:(NSString *)path
{
    // add trailing slash if needed
    if(![path hasSuffix:@"/"])
        path = [NSString stringWithFormat:@"%@/", path];
    NSRange range = [self rangeOfString:path];
    if(range.location != NSNotFound && range.location == 0)
        return [self substringFromIndex:range.location+range.length];
    
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



