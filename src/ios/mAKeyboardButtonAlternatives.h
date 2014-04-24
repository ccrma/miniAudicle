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
@property (strong, nonatomic) NSArray *alternatives;

- (id)initWithAlternatives:(NSArray *)alternatives;

@end
