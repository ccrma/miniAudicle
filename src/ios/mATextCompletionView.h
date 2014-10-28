//
//  mATextCompletionView.h
//  miniAudicle
//
//  Created by Spencer Salazar on 8/29/14.
//
//

#import <UIKit/UIKit.h>

@interface mATextCompletionView : UIControl

@property (copy, readonly, nonatomic) NSString *selectedCompletion;
@property (copy, nonatomic) NSArray *completions;
@property (copy, nonatomic) NSDictionary *textAttributes;

@end
