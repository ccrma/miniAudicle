//
//  mADetailItem.m
//  miniAudicle
//
//  Created by Spencer Salazar on 3/27/14.
//
//

#import "mADetailItem.h"
#import "mAChuckController.h"
#import "miniAudicle.h"
#import "mANetworkAction.h"
#import "mANetworkManager.h"
#import "mADocumentManager.h"
#import "mAAnalytics.h"

#import "KVOMutableArray.h"
#import "NSString+Hash.h"

NSString * const mADetailItemTitleChangedNotification = @"mADetailItemTitleChangedNotification";
NSString * const mADetailItemDeletedNotification = @"mADetailItemDeletedNotification";


@interface NSFileManager (isDirectory)

- (BOOL)isDirectory:(NSString *)path;

@end

@implementation NSFileManager (isDirectory)

- (BOOL)isDirectory:(NSString *)path
{
    BOOL isDirectory = NO;
    if([self fileExistsAtPath:path isDirectory:&isDirectory])
        return isDirectory;
    else
        return NO;
}


@end

@interface mADetailItem ()

- (NSString *)generateUUID;

@end


@implementation mADetailItem

- (NSString *)uuid
{
    if(_uuid == nil)
        _uuid = [self generateUUID];
    return _uuid;
}

- (NSString *)text
{
    if(_text == nil)
    {
        NSError *error = nil;
        _text = [NSString stringWithContentsOfFile:self.path encoding:NSUTF8StringEncoding error:&error];
        mAAnalyticsLogError(error);
        if(error)
            _text = @"";
    }
    
    return _text;
}

- (BOOL)isFolder
{
    return self.type == DETAILITEM_DIRECTORY;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.uuid = [self generateUUID];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:mADetailItemTitleChangedNotification object:self];
}

+ (mADetailItem *)detailItemFromPath:(NSString *)path isUser:(BOOL)isUser
{
    mADetailItem * detailItem = [mADetailItem new];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    detailItem.path = path;
    detailItem.title = [path lastPathComponent];
    detailItem.isUser = isUser;
    
    NSString *extension = [detailItem.path pathExtension];
    if([fileManager isDirectory:path])
        detailItem.type = DETAILITEM_DIRECTORY;
    else if([extension isEqualToString:@"ck"])
        detailItem.type = DETAILITEM_CHUCK_SCRIPT;
    else if([extension isEqualToString:@"wav"] || [extension isEqualToString:@"aif"] || [extension isEqualToString:@"aiff"])
        detailItem.type = DETAILITEM_AUDIO_FILE;
    else
        detailItem.type = DETAILITEM_MISC;
    
    // NSLog(@"document uuid: %@", detailItem.uuid);
    
    return detailItem;
}

+ (mADetailItem *)folderDetailItemWithTitle:(NSString *)title
                                      items:(NSMutableArray *)items
                                     isUser:(BOOL)user;
{
    mADetailItem * detailItem = [mADetailItem new];
    
    detailItem.isUser = user;
    detailItem.title = title;
    detailItem.text = nil;
    detailItem.type = DETAILITEM_DIRECTORY;
    
    if([items isKindOfClass:[KVOMutableArray class]])
        detailItem.folderItems = items;
    else
        detailItem.folderItems = [[KVOMutableArray alloc] initWithMutableArray:items];
    
    return detailItem;
}

+ (mADetailItem *)remoteDetailItemWithNewScriptAction:(mANANewScript *)action
{
    mADetailItem * detailItem = [mADetailItem new];
    
    detailItem.remote = YES;
    detailItem.remoteUUID = action.code_id;
    detailItem.remoteUsername = [[mANetworkManager instance] usernameForUserID:action.user_id];
    detailItem.title = action.name;
    detailItem.text = action.code;
    
    return detailItem;
}

- (id)init
{
    if(self = [super init])
    {
        self.docid = UINT_MAX;
        self.remote = NO;
        self.hasLocalEdits = NO;
    }
    
    return self;
}

- (void)dealloc
{
    if(_docid != UINT_MAX)
    {
        [mAChucKController chuckController].ma->free_document_id(_docid);
        _docid = UINT_MAX;
    }
}

- (void)save
{
    NSError *error = NULL;
    
    if(self.type == DETAILITEM_CHUCK_SCRIPT && self.isUser)
    {
        [self.text writeToFile:self.path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        mAAnalyticsLogError(error);
    }
}

- (void)rename:(NSString *)title
{
}

- (t_CKUINT)docid
{
    if(_docid == UINT_MAX)
    {
        _docid = [mAChucKController chuckController].ma->allocate_document_id();
    }
    
    return _docid;
}

- (NSDictionary *)dictionary
{
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    
    [dictionary setObject:[NSNumber numberWithBool:self.isUser] forKey:@"isUser"];
    [dictionary setObject:self.title forKey:@"title"];
    [dictionary setObject:self.text forKey:@"text"];
    
    return [NSDictionary dictionaryWithDictionary:dictionary];
}

- (NSString *)generateUUID
{
    return [[[NSString stringWithFormat:@"%@:%@",
              self.title,
              [UIDevice currentDevice].identifierForVendor]
             sha1] base64EncodedStringWithOptions:0];
}

- (NSString *)description
{
    return self.title;
}

@end


