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
@property (strong, nonatomic) void (^button1Handler)();
@property (strong, nonatomic) void (^button2Handler)();
@property (strong, nonatomic) void (^inputHandler)(NSString *);

@end


void UIAlertMessage(NSString *message, void (^okHandler)())
{
    UIAlertHelper *helper = [UIAlertHelper new];
    helper.button1Handler = okHandler;
    helper.strongSelf = helper;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                        message:nil
                                                       delegate:helper
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

void UIAlertMessage1a(NSString *title, NSString *message, void (^okHandler)())
{
    UIAlertHelper *helper = [UIAlertHelper new];
    helper.button1Handler = okHandler;
    helper.strongSelf = helper;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:helper
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [alertView show];
}

void UIAlertMessage2(NSString *message,
                     NSString *button1, void (^button1Handler)(),
                     NSString *button2, void (^button2Handler)())
{
    UIAlertHelper *helper = [UIAlertHelper new];
    helper.button1Handler = button1Handler;
    helper.button2Handler = button2Handler;
    helper.strongSelf = helper;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:message
                                                        message:nil
                                                       delegate:helper
                                              cancelButtonTitle:button1
                                              otherButtonTitles:button2, nil];
    
    [alertView show];
}

void UIAlertMessage2a(NSString *title, NSString *message,
                      NSString *button1, void (^button1Handler)(),
                      NSString *button2, void (^button2Handler)())
{
    UIAlertHelper *helper = [UIAlertHelper new];
    helper.button1Handler = button1Handler;
    helper.button2Handler = button2Handler;
    helper.strongSelf = helper;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:helper
                                              cancelButtonTitle:button1
                                              otherButtonTitles:button2, nil];
    
    [alertView show];
}

void UIAlertMessageInput(NSString *title, NSString *message,
                         void (^handler)(NSString *))
{
    UIAlertHelper *helper = [UIAlertHelper new];
    helper.inputHandler = handler;
    helper.strongSelf = helper;
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:helper
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    [alertView show];
}


@implementation UIAlertHelper

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(self.inputHandler)
    {
        NSString *input = [alertView textFieldAtIndex:0].text;
        self.inputHandler(input);
    }
    else if(buttonIndex == 0)
    {
        if(self.button1Handler) self.button1Handler();
    }
    else if(buttonIndex == 1)
    {
        if(self.button2Handler) self.button2Handler();
    }
    
    self.strongSelf = nil;
}

@end