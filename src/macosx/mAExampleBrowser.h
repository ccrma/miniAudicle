//
//  mAExampleBrowser.h
//  miniAudicle
//
//  Created by Spencer Salazar on 6/13/13.
//
//

#import <Cocoa/Cocoa.h>

@interface mAExampleBrowser : NSWindowController <NSBrowserDelegate>
{
    IBOutlet NSBrowser * _browser;
}

- (IBAction)open:(id)sender;
- (IBAction)cancel:(id)sender;

@end
