//
//  mASocialDetailItem.m
//  miniAudicle
//
//  Created by Spencer Salazar on 7/26/16.
//
//

#import "mASocialDetailItem.h"

#import "ChuckPadSocial.h"
#import "Patch.h"

@implementation mASocialDetailItem

+ (mASocialDetailItem *)socialDetailItemWithPatch:(Patch *)patch
{
    mASocialDetailItem *item = [mASocialDetailItem new];
    item.patch = patch;
    item.isUser = NO;
    
    item.title = patch.name;
    item.text = nil;
    item.type = DETAILITEM_CHUCK_SCRIPT;
    
    return item;
}

- (BOOL)isSocial
{
    return YES;
}

- (BOOL)isLoaded
{
    return NO;
}

- (void)load:(void (^)(BOOL success, NSError *error))callback
{
    NSURLSession *urlSession = [NSURLSession sharedSession];
    NSURLSessionDataTask *task;
    NSLog(@"%@", [self.patch getResourceUrl]);
    task = [urlSession dataTaskWithURL:[NSURL URLWithString:[self.patch getResourceUrl]]
                     completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                         int statusCode = -1;
                         if([response isKindOfClass:[NSHTTPURLResponse class]])
                             statusCode = [(NSHTTPURLResponse *)response statusCode];
                         if(error == nil && (statusCode == 200 || statusCode == -1))
                         {
                             self.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                             callback(YES, nil);
                         }
                         else
                         {
                             callback(NO, error);
                         }
                     }];
    [task resume];
}

- (void)save
{
    // 
}

@end
