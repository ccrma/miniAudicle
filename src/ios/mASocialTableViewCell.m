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
    IBOutlet UILabel *_dateLabel;
    IBOutlet UILabel *_viewsLabel;
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
    if(desc == nil || [desc length] == 0)
    {
        _descriptionLabel.text = @"No description";
        _descriptionLabel.font = [UIFont italicSystemFontOfSize:_descriptionLabel.font.pointSize];
    }
    else
    {
        _descriptionLabel.text = desc;
        _descriptionLabel.font = [UIFont systemFontOfSize:_descriptionLabel.font.pointSize];
    }
}

- (void)setCategory:(NSString *)category
{
    _category = category;
    _categoryLabel.text = category;
}

- (void)setNumViews:(NSInteger *)numViews
{
    _numViews = numViews;
    _viewsLabel.text = [NSString stringWithFormat:@"%li views", (long int)numViews];
}

- (void)setDate:(NSString *)date
{
    _date = date;
    _dateLabel.text = date;
}

- (void)awakeFromNib
{
    self.name = @"";
    self.category = @"";
    self.desc = @"";
    self.date = @"";
    self.numViews = 0;
}

@end
