//
//  mATextView.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/24/14.
//
//

#import <UIKit/UIKit.h>

@interface mATextView : UITextView

@property (nonatomic) NSInteger errorLine;
@property (copy, nonatomic) NSString *errorMessage;

@end

