//
//  mAInteractionModeController.h
//  miniAudicle
//
//  Created by Spencer Salazar on 7/26/16.
//
//

#import <Foundation/Foundation.h>

/** In miniAudicle, an Interaction Mode is a high-level framework for how scripts
 * are interacted with.
 */
@protocol mAInteractionModeController <NSObject>

/**
 * Return list of menu items that should appear in the document menu in the
 * main toolbar.
 * @return menuItems An array of strings that will be used as the title for
 * each menu item.
 */
- (NSArray<NSString *> *)menuItems;

/**
 * Handle the specified menu item.
 * @param item The menu item that was selected from the array given by the array
 * returned by menuItems.
 */
- (void)handleMenuItem:(NSInteger)item;

/**
 * Return title button.
 * @return A UIBarButtonItem for the title of this interaction mode.
 */
- (UIBarButtonItem *)titleButton;

@end
