//
//  mATableViewCell.m
//  miniAudicle
//
//  Created by Spencer Salazar on 6/11/16.
//
//

#import "mATableViewCell.h"
#import "mADetailItem.h"

@implementation mATableViewCell

- (void)setItem:(mADetailItem *)item
{
    // remove observer from old item
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:mADetailItemTitleChangedNotification
                                                  object:_item];
    
    _item = item;
    self.textLabel.text = item.title;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(detailItemTitleChanged:)
                                                 name:mADetailItemTitleChangedNotification
                                               object:item];
}

- (void)detailItemTitleChanged:(NSNotification *)n
{
    self.textLabel.text = self.item.title;
}

@end
