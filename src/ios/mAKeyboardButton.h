//
//  mAKeyboardButton.h
//  miniAudicle
//
//  Created by Spencer Salazar on 3/24/14.
//
//

#import <UIKit/UIKit.h>

@interface mAKeyboardButton : UIButton

@property (strong, readonly, nonatomic) NSString *pressedKey;
@property (strong, nonatomic) NSArray *alternatives;
@property (strong, nonatomic) NSArray *attributes;

@property (strong, nonatomic) NSString *keyInsertText;
@property (nonatomic) NSInteger cursorOffset;

@end
