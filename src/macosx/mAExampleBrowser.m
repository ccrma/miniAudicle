//
//  mAExampleBrowser.m
//  miniAudicle
//
//  Created by Spencer Salazar on 6/13/13.
//
//

#import "mAExampleBrowser.h"

@interface mAExampleBrowser ()

@end

@implementation mAExampleBrowser

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self)
    {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [_browser setDoubleAction:@selector(open:)];
    [_browser setTarget:self];
}

- (IBAction)open:(id)sender
{
//    [self.window close];

    NSString * examplePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"examples"];
    NSString * columnPath = [examplePath stringByAppendingFormat:@"/%@", [_browser path]];
    [[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:columnPath]
                                                                           display:YES
                                                                             error:nil];
}

- (IBAction)cancel:(id)sender
{
    [self.window close];
}


#pragma mark NSBrowserDelegate

- (NSInteger)browser:(NSBrowser *)sender numberOfRowsInColumn:(NSInteger)column
{
    NSString * examplePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"examples"];
    NSString * columnPath = [examplePath stringByAppendingFormat:@"/%@", [sender pathToColumn:column]];
    return [[[NSFileManager defaultManager] contentsOfDirectoryAtPath:columnPath error:nil] count];
}

- (void)browser:(NSBrowser *)sender willDisplayCell:(id)cell atRow:(NSInteger)row column:(NSInteger)column
{
    NSString * file;
    NSString * fullpath;

    NSString * examplePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"examples"];
    NSString * columnPath = [examplePath stringByAppendingFormat:@"/%@", [sender pathToColumn:column]];
    NSArray * files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:columnPath error:nil];
    file = [files objectAtIndex:row];
    fullpath = [columnPath stringByAppendingPathComponent:file];
    
    [cell setTitle:file];
    
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:fullpath isDirectory:&isDirectory];
    if(isDirectory)
    {
        [cell setImage:[[NSBundle mainBundle] imageForResource:@"folder.png"]];
        [cell setLeaf:NO];
    }
    else
    {
        [cell setImage:[[NSBundle mainBundle] imageForResource:@"ckmini.png"]];
        [cell setLeaf:YES];
    }
}

- (CGFloat)browser:(NSBrowser *)browser heightOfRow:(NSInteger)row inColumn:(NSInteger)columnIndex
{
    return 64;
}

@end
