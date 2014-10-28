//
//  mAKeyboardButtonAlternatives.h
//  miniAudicle
//
//  Created by Spencer Salazar on 4/23/14.
//
//

#import <UIKit/UIKit.h>

@interface mAKeyboardButtonAlternatives : UIControl

@property (strong, readonly, nonatomic) NSString *pressedKey;
@property (copy, nonatomic) NSArray *alternatives;
@property (copy, nonatomic) NSArray *attributes;
@property (nonatomic) NSInteger cursorOffset;

- (id)initWithAlternatives:(NSArray *)alternatives;

@end
