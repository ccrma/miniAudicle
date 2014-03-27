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

@implementation mADetailItem

+ (mADetailItem *)detailItemFromDictionary:(NSDictionary *)dictionary
{
    mADetailItem * detailItem = [mADetailItem new];
    
    detailItem.isUser = [[dictionary objectForKey:@"isUser"] boolValue];
    detailItem.title = [dictionary objectForKey:@"title"];
    detailItem.text = [dictionary objectForKey:@"text"];
    
    detailItem.isFolder = NO;
    detailItem.folderItems = nil;
    
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
    
    detailItem.isFolder = YES;
    detailItem.folderItems = items;
    
    return detailItem;
}

- (id)init
{
    if(self = [super init])
    {
        self.docid = UINT_MAX;
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

@end


