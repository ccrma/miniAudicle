//
//  mAExampleBrowser.h
//  miniAudicle
//
//  Created by Spencer Salazar on 6/13/13.
//
//

#import <Cocoa/Cocoa.h>

@interface mAExampleBrowser : NSWindowController <NSBrowserDelegate, NSWindowDelegate>
{
    IBOutlet NSBrowser * _browser;
    IBOutlet NSButton * _openButton;
}

- (IBAction)open:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)select:(id)sender;

@end
