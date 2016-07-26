//
//  mAFolderTableViewCell.m
//  miniAudicle
//
//  Created by Spencer Salazar on 5/14/16.
//
//

#import "mASocialTableViewCell.h"
#import "mAAnalytics.h"

@interface mASocialTableViewCell ()
{
    IBOutlet UILabel *_nameLabel;
    IBOutlet UILabel *_categoryLabel;
    IBOutlet UILabel *_descriptionLabel;
}

@end

@implementation mASocialTableViewCell

- (void)setName:(NSString *)name
{
    _name = name;
    _nameLabel.text = name;
}

- (void)setDesc:(NSString *)desc
{
    _desc = desc;
    _descriptionLabel.text = desc;
}

- (void)setCategory:(NSString *)category
{
    _category = category;
    _categoryLabel.text = category;
}

- (void)awakeFromNib
{
    self.name = @"";
    self.category = @"";
    self.desc = @"";
}

@end
