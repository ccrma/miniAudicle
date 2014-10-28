//
//  UIAlert.m
//  miniAudicle
//
//  Created by Spencer Salazar on 8/5/14.
//
//

#import "UIAlert.h"


@interface UIAlertHelper : NSObject<UIAlertViewDelegate>

@property (strong, nonatomic) id strongSelf; // HACK
@property (strong, nonatomic) void (^okHandler)();

@end


void UIAlertMessage(NSString *message, void (^okHandler)())
{
    UIAlertHelper *helper = [UIAlertHelper new];
    helper.okHandler = okHandler;
    helper.strongSelf = helper;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                        message:nil
                                                       delegate:helper
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}


@implementation UIAlertHelper

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(self.okHandler) self.okHandler();
    self.strongSelf = nil;
}

@end