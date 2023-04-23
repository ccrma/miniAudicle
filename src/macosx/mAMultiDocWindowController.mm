/*----------------------------------------------------------------------------
 miniAudicle
 Cocoa GUI to chuck audio programming environment
 
 Copyright (c) 2005-2013 Spencer Salazar.  All rights reserved.
 http://chuck.cs.princeton.edu/
 http://soundlab.cs.princeton.edu/
 
 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
 U.S.A.
 -----------------------------------------------------------------------------*/

/* Based in part on: */
//
//  MultiDocWindowController.m
//  MultiDocTest
//
//  Created by Cartwright Samuel on 3/14/13.
//  Copyright (c) 2013 Samuel Cartwright. All rights reserved.
//

/* Also based in part on: */
//
//  WindowController.m
//  PSMTabBarControl
//
//  Created by John Pannell on 4/6/06.
//  Copyright 2006 Positive Spin Media. All rights reserved.
//

#import "mAMultiDocWindowController.h"
#import "miniAudicleDocument.h"
#import "miniAudicleController.h"
#import "mADocumentViewController.h"
#import "miniAudiclePreferencesController.h"
#import <PSMTabBarControl/PSMTabStyle.h>


@interface NSTabViewItem (mAMultiDocWindowController)

- (mADocumentViewController *)documentViewController;

@end

@implementation NSTabViewItem (mAMultiDocWindowController)

- (mADocumentViewController *)documentViewController
{
    return (mADocumentViewController *)[self identifier];
}

@end


@interface mAMultiDocWindowController ()

@property (nonatomic,retain,readonly) NSMutableSet* documents;
@property (nonatomic,retain,readonly) NSMutableSet* contentViewControllers;

@end

@implementation mAMultiDocWindowController

@synthesize documents = _documents;
@synthesize contentViewControllers = _contentViewControllers;

- (NSMutableSet *)documents {
    if (!_documents) {
        _documents = [[NSMutableSet alloc] initWithCapacity:3];
    }
    return _documents;
}

- (NSMutableSet *)contentViewControllers {
    if (!_contentViewControllers) {
        _contentViewControllers = [[NSMutableSet alloc] initWithCapacity:3];
    }
    return _contentViewControllers;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        _showsToolbar = YES;
        _showsTabBar = YES;
        _vm_on = NO;
    }
    
    return self;
}

- (void)dealloc
{
    for(miniAudicleDocument * doc in self.documents)
    {
        [doc removeWindowController:self];
        [doc setWindowController:nil];
    }
    
    [[NSUserDefaultsController sharedUserDefaultsController]
     removeObserver:self
     forKeyPath:[NSString stringWithFormat:@"values.%@", mAPreferencesShowTabBar]];
    [[NSUserDefaultsController sharedUserDefaultsController]
     removeObserver:self
     forKeyPath:[NSString stringWithFormat:@"values.%@", mAPreferencesShowToolbar]];

    [_documents release];
    _documents = nil;
    [_contentViewControllers release];
    _contentViewControllers = nil;

    tabView = nil;
    tabBar = nil;
    _toolbar = nil;
    
    [super dealloc];
}

- (PSMTabBarControl *)tabBar
{
    return tabBar;
}

- (unsigned int)numberOfTabs
{
    return [tabView numberOfTabViewItems];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
//    [tabBar retain];
    
    [tabBar hideTabBar:!_showsTabBar animate:NO];
    [tabBar setHideForSingleTab:!_showsTabBar];
    [tabBar setCanCloseOnlyTab:YES];
    [tabBar setSizeCellsToFit:YES];
    [tabBar setAllowsResizing:YES];
    [tabBar setAlwaysShowActiveTab:NO];
//    [tabBar setHideForSingleTab:YES];
    [tabBar setShowAddTabButton:YES];
    [tabBar setStyleNamed:@"Metal"];
    [[tabBar addTabButton] setTarget:self];
    [[tabBar addTabButton] setAction:@selector(newDocument:)];
    
    [[NSUserDefaultsController sharedUserDefaultsController]
     addObserver:self
     forKeyPath:[NSString stringWithFormat:@"values.%@", mAPreferencesShowTabBar]
     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
     context:nil];
    [[NSUserDefaultsController sharedUserDefaultsController]
     addObserver:self
     forKeyPath:[NSString stringWithFormat:@"values.%@", mAPreferencesShowToolbar]
     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
     context:nil];
    
// add views for any documents that were added before the window was created
    for(NSDocument* document in self.documents)
        [self addViewWithDocument:document tabViewItem:nil];
    
    [[self window] setShowsToolbarButton:YES];

//    NSButton * toolbar_pill = [[self window] standardWindowButton:NSWindowToolbarButton];
//    [toolbar_pill setTarget:self];
//    [toolbar_pill setAction:@selector(toggleToolbar:)];
    
    if([[self window] isMainWindow])
    {
        CGFloat colors[] = { 175.0/255.0, 175.0/255.0, 175.0/255.0, 1.0 };
        [[self window] setBackgroundColor:[NSColor colorWithColorSpace:[NSColorSpace sRGBColorSpace]
                                                            components:colors
                                                                 count:4]];
    }
    else
    {
        CGFloat colors[] = { 223.0/255.0, 223.0/255.0, 223.0/255.0, 1.0 };
        [[self window] setBackgroundColor:[NSColor colorWithColorSpace:[NSColorSpace sRGBColorSpace]
                                                            components:colors
                                                                 count:4]];

    }
}

- (void)addViewWithDocument:(NSDocument*)document tabViewItem:(NSTabViewItem *)tabViewItem
{
    mADocumentViewController *ctrl;

    if(tabViewItem == nil)
    {
        ctrl = (mADocumentViewController *)[(miniAudicleDocument *)document newPrimaryViewController];
        
        tabViewItem = [[[NSTabViewItem alloc] initWithIdentifier:ctrl] autorelease];
        [tabViewItem setView:ctrl.view];
        [tabViewItem setLabel:[document displayName]];
        
        NSUInteger tabIndex = [tabView numberOfTabViewItems];
        [tabView insertTabViewItem:tabViewItem atIndex:tabIndex];
        [tabView selectTabViewItem:tabViewItem];
    }
    else
    {
        ctrl = (mADocumentViewController *)[tabViewItem identifier];
    }
    
    ctrl.windowController = self;
    [self.contentViewControllers addObject:ctrl];
    
    [ctrl activate];
    
    [document setWindow:self.window];
    [(miniAudicleDocument *)document setWindowController:self];
}

- (void)addDocument:(NSDocument *)docToAdd
{
    [self addDocument:docToAdd tabViewItem:nil];
}

- (void)addDocument:(NSDocument *)docToAdd tabViewItem:(NSTabViewItem *)tabViewItem
{
    NSMutableSet* documents = self.documents;
    if ([documents containsObject:docToAdd])
        return;
    
    [documents addObject:docToAdd];
    
    [docToAdd addObserver:self forKeyPath:@"fileURL" options:0 context:0];
    
    // check if the window has been created. We can not insert new tab
    // items until the nib has been loaded. So if the window isnt created
    // yet, do nothing and instead add the view controls during the
    // windowDidLoad function
    
    if(self.isWindowLoaded)
        [self addViewWithDocument:docToAdd tabViewItem:tabViewItem];
}

- (void)removeDocument:(NSDocument *)docToRemove
{
    [self removeDocument:docToRemove attachedToViewController:[(miniAudicleDocument *)docToRemove viewController]];
}

- (void)removeDocument:(NSDocument *)_docToRemove attachedToViewController:(NSViewController*)ctrl
{
    miniAudicleDocument * docToRemove = (miniAudicleDocument *) _docToRemove;
    NSMutableSet* documents = self.documents;
    if (![documents containsObject:docToRemove])
        return;
    
    // remove the document's view controller and view
    [(id)ctrl setWindowController:nil];
    
    // remove the view from the tab item
    // dont remove the tab view item from the tab view, as this is handled by the framework (when
    // we click on the close button on the tab) - of course it wouldnt be if you closed the document
    // using the menu (TODO)
    NSInteger index = [tabView indexOfTabViewItemWithIdentifier:ctrl];
    if(index != NSNotFound)
    {
        //[tabViewItem setView: nil];
        [tabView removeTabViewItem:[tabView tabViewItemAtIndex:index]];
    }
    
    // remove the control from the view controllers set
    [self.contentViewControllers removeObject:ctrl];
    
    // finally detach the document from the window controller
    [docToRemove removeWindowController:self];
    if(docToRemove.windowController == self)
        [docToRemove setWindowController:nil];
    [documents removeObject:docToRemove];
    
    [docToRemove removeObserver:self forKeyPath:@"fileURL"];
}

- (void)document:(NSDocument *)doc wasEdited:(BOOL)edited;
{
    mADocumentViewController *viewController = [(miniAudicleDocument *)doc viewController];
    if(viewController == (mADocumentViewController *)[[tabView selectedTabViewItem] identifier])
        [[self window] setDocumentEdited:edited];
}

- (void)updateTitles
{
    NSTabViewItem *tabViewItem = [tabView selectedTabViewItem];
    NSViewController* ctrl = (NSViewController*)[tabViewItem identifier];
    NSDocument* doc = [(id)ctrl document];
    [[self window] setTitle:[doc displayName]];
    [tabViewItem setLabel:[doc displayName]];
}

- (void)setDocument:(NSDocument *)document
{
    // NSLog(@"Will not set document to: %@",document);
}

- (NSDocument *)document
{
    NSTabViewItem *tabViewItem = [tabView selectedTabViewItem];
    NSViewController* ctrl = (NSViewController*)tabViewItem.identifier;
    
    return [(id) ctrl document];
}

- (void)showTabForDocument:(NSDocument *)doc
{
    for (NSTabViewItem* tabViewItem in [tabView tabViewItems]) {
        mADocumentViewController* docViewCtrl = [tabViewItem documentViewController];
        if ([docViewCtrl document] == doc) {
            [tabView selectTabViewItem:tabViewItem];
            [docViewCtrl activate];
            [self showWindow:nil];
            break;
        }
    }
}


- (IBAction)closeTab:(id)sender
{
    NSViewController* ctrl = (NSViewController*)[[tabView selectedTabViewItem] identifier];
    NSDocument* doc = [(id)ctrl document];
    
    [doc canCloseDocumentWithDelegate:self
                  shouldCloseSelector:@selector(document:shouldClose:contextInfo:)
                          contextInfo:nil];
}

- (void)document:(NSDocument *)document shouldClose:(BOOL)shouldClose contextInfo:(void *)contextInfo
{
    if(shouldClose)
    {
        [document close];
        
        if([tabView numberOfTabViewItems] == 0)
        {
            [self.window close];
            [(miniAudicleController *)[NSDocumentController sharedDocumentController] windowDidCloseForController:self];
        }
    }
}

- (void)newDocument:(id)sender
{
    [[self window] makeKeyAndOrderFront:sender];
    [[NSDocumentController sharedDocumentController] newTab:sender];
}

- (NSViewController *)currentViewController
{
    return (NSViewController*)[[tabView selectedTabViewItem] identifier];
}

#pragma mark NSTabView + PSMTabBarControl delegate methods

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    NSViewController* ctrl = (NSViewController*)[tabViewItem identifier];
    NSDocument* doc = [(id)ctrl document];
    
    [[self window] setDocumentEdited:[doc isDocumentEdited]];
    [[self window] setTitle:[doc displayName]];
    [[self window] setRepresentedURL:[doc fileURL]];
}

- (BOOL)tabView:(NSTabView *)aTabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
    NSViewController* ctrl = (NSViewController*)[tabViewItem identifier];
    NSDocument* doc = [(id)ctrl document];
    
    [doc canCloseDocumentWithDelegate:self
                  shouldCloseSelector:@selector(document:shouldClose:contextInfo:)
                          contextInfo:nil];
    
    return NO;
}

- (void)tabView:(NSTabView *)aTabView willCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
    // NSLog(@"tabView willCloseTabViewItem");
}

- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem
{
//    NSLog(@"tabView didCloseTabViewItem");
}

- (void)tabView:(NSTabView *)aTabView didDetachTabViewItem:(NSTabViewItem *)tabViewItem
{
    // NSLog(@"Did Detach Tab View Item");    
}

- (void)tabView:(NSTabView *)aTabView acceptedDraggingInfo:(id <NSDraggingInfo>)draggingInfo onTabViewItem:(NSTabViewItem *)tabViewItem
{
//	NSLog(@"acceptedDraggingInfo: %@ onTabViewItem: %@", [[draggingInfo draggingPasteboard] stringForType:[[[draggingInfo draggingPasteboard] types] objectAtIndex:0]], [tabViewItem label]);
}

- (BOOL)tabView:(NSTabView*)aTabView shouldDragTabViewItem:(NSTabViewItem *)tabViewItem fromTabBar:(PSMTabBarControl *)tabBarControl
{
	return YES;
}

- (BOOL)tabView:(NSTabView*)aTabView shouldDropTabViewItem:(NSTabViewItem *)tabViewItem inTabBar:(PSMTabBarControl *)tabBarControl
{
    //NSLog(@"shouldDropTabViewItem: %@ inTabBar: %@", [tabViewItem label], tabBarControl);
    
	return YES;
}

- (void)tabView:(NSTabView*)aTabView didDropTabViewItem:(NSTabViewItem *)tabViewItem inTabBar:(PSMTabBarControl *)tabBarControl
{
//	NSLog(@"didDropTabViewItem: %@ inTabBar: %@", [tabViewItem label], tabBarControl);
    
    mADocumentViewController *ctrl = (mADocumentViewController *)[tabViewItem identifier];
    miniAudicleDocument *doc = [ctrl document];
    
    // hold on to these for now
    [[ctrl retain] autorelease];
    [[doc retain] autorelease];

    [self removeDocument:doc attachedToViewController:ctrl];
    
    mAMultiDocWindowController * newWindowController = [[tabBarControl window] windowController];
    [newWindowController addDocument:doc tabViewItem:tabViewItem];
    [[tabBarControl window] makeKeyAndOrderFront:self];
    [ctrl activate];
    [[tabBarControl window] setDocumentEdited:[doc isDocumentEdited]];
}

- (NSImage *)tabView:(NSTabView *)aTabView imageForTabViewItem:(NSTabViewItem *)tabViewItem offset:(NSSize *)offset styleMask:(NSUInteger *)styleMask
{
	// grabs whole window image
	NSImage *viewImage = [[[NSImage alloc] init] autorelease];
	NSRect contentFrame = [[[self window] contentView] frame];
	[[[self window] contentView] lockFocus];
	NSBitmapImageRep *viewRep = [[[NSBitmapImageRep alloc] initWithFocusedViewRect:contentFrame] autorelease];
	[viewImage addRepresentation:viewRep];
	[[[self window] contentView] unlockFocus];
	
    // grabs snapshot of dragged tabViewItem's view (represents content being dragged)
	NSView *viewForImage = [tabViewItem view];
	NSRect viewRect = [viewForImage frame];
	NSImage *tabViewImage = [[[NSImage alloc] initWithSize:viewRect.size] autorelease];
	[tabViewImage lockFocus];
	[viewForImage drawRect:[viewForImage bounds]];
	[tabViewImage unlockFocus];
	
	[viewImage lockFocus];
	NSPoint tabOrigin = [tabView frame].origin;
	tabOrigin.x += 10;
	tabOrigin.y += 13;
	[tabViewImage drawAtPoint:tabOrigin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[viewImage unlockFocus];
	
	//draw over where the tab bar would usually be
	NSRect tabFrame = [tabBar frame];
	[viewImage lockFocus];
	[[NSColor windowBackgroundColor] set];
	NSRectFill(tabFrame);
	//draw the background flipped, which is actually the right way up
	NSAffineTransform *transform = [NSAffineTransform transform];
	[transform scaleXBy:1.0 yBy:-1.0];
	[transform concat];
	tabFrame.origin.y = -tabFrame.origin.y - tabFrame.size.height;
	[(id <PSMTabStyle>)[tabBar style] drawBackgroundInRect:tabFrame];
	[transform invert];
	[transform concat];
	
	[viewImage unlockFocus];
	
	if ([tabBar orientation] == PSMTabBarHorizontalOrientation) {
		offset->width = [(id <PSMTabStyle>)[tabBar style] leftMarginForTabBarControl];
		offset->height = 22;
	} else {
		offset->width = 0;
		offset->height = 22 + [(id <PSMTabStyle>)[tabBar style] leftMarginForTabBarControl];
	}
	
	if (styleMask) {
		*styleMask = NSTitledWindowMask | NSTexturedBackgroundWindowMask;
	}
	
	return viewImage;
}

- (PSMTabBarControl *)tabView:(NSTabView *)aTabView newTabBarForDraggedTabViewItem:(NSTabViewItem *)tabViewItem atPoint:(NSPoint)point
{
//	NSLog(@"newTabBarForDraggedTabViewItem: %@ atPoint: %@", [tabViewItem label], NSStringFromPoint(point));
	
	//create a new window controller with no tab items
	mAMultiDocWindowController *newWindowController = [(miniAudicleController *)[NSDocumentController sharedDocumentController] newWindowController];
	id <PSMTabStyle> style = (id <PSMTabStyle>)[tabBar style];
	
	NSRect windowFrame = [[newWindowController window] frame];
	point.y += windowFrame.size.height - [[[newWindowController window] contentView] frame].size.height;
	point.x -= [style leftMarginForTabBarControl];
	
	[[newWindowController window] setFrameTopLeftPoint:point];
	[[newWindowController tabBar] setStyle:style];
	
	return [newWindowController tabBar];
}

- (void)tabView:(NSTabView *)aTabView closeWindowForLastTabViewItem:(NSTabViewItem *)tabViewItem
{
    [self.window close];
    [(miniAudicleController *)[NSDocumentController sharedDocumentController] windowDidCloseForController:self];
}


#pragma mark NSWindowDelegate

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    CGFloat colors[] = { 175.0/255.0, 175.0/255.0, 175.0/255.0, 1.0 };
    [[self window] setBackgroundColor:[NSColor colorWithColorSpace:[NSColorSpace sRGBColorSpace]
                                                        components:colors
                                                             count:4]];
    [tabBar setNeedsDisplay];
}

- (void)windowDidResignMain:(NSNotification *)notification
{
    CGFloat colors[] = { 223.0/255.0, 223.0/255.0, 223.0/255.0, 1.0 };
    [[self window] setBackgroundColor:[NSColor colorWithColorSpace:[NSColorSpace sRGBColorSpace]
                                                        components:colors
                                                             count:4]];
    [tabBar setNeedsDisplay];
}

- (BOOL)windowShouldClose:(id)sender
{
    int numUnsaved = 0;
    
    for(NSDocument * doc in self.documents)
    {
        if([doc isDocumentEdited])
            numUnsaved++;
    }
    
    if(numUnsaved > 0)
    {
        NSString *messageText = [NSString stringWithFormat:@"You have %i miniAudicle documents with unsaved changes. Do you want to review these changes before quitting?",
                                 numUnsaved];
        
        NSAlert * alert = [NSAlert alertWithMessageText:messageText
                                          defaultButton:@"Review Changes..."
                                        alternateButton:@"Cancel"
                                            otherButton:@"Discard Changes"
                              informativeTextWithFormat:@"If you don’t review your documents, all your changes will be lost."];
        
        [alert beginSheetModalForWindow:[self window]
                          modalDelegate:self
                         didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                            contextInfo:nil];
        
        return NO;
    }
    else
    {
        NSSet *documentsCopy = [[self.documents copy] autorelease];
        for(NSDocument * doc in documentsCopy)
        {
            [doc close];
        }
        
        [(miniAudicleController *)[NSDocumentController sharedDocumentController] windowDidCloseForController:self];

        return YES;
    }
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [[alert window] orderOut:self];
    
    if(returnCode == NSAlertDefaultReturn)
    {
        NSSet *documentsCopy = [[self.documents copy] autorelease];
        for(NSDocument * doc in documentsCopy)
        {
            [doc canCloseDocumentWithDelegate:self
                          shouldCloseSelector:@selector(document:shouldClose:contextInfo:)
                                  contextInfo:nil];
        }
    }
    else if(returnCode == NSAlertAlternateReturn)
    {
    }
    else if(returnCode == NSAlertOtherReturn)
    {
        NSSet *documentsCopy = [[self.documents copy] autorelease];
        for(NSDocument * doc in documentsCopy)
        {
            [doc close];
        }

        [self.window close];
        [(miniAudicleController *)[NSDocumentController sharedDocumentController] windowDidCloseForController:self];
    }
}


- (void)flagsChanged:(NSEvent *)theEvent
{
    if([theEvent modifierFlags] & NSAlternateKeyMask)
    {
        [_addShredToolbarItem setLabel:@"Add Tabs "];
        [_replaceShredToolbarItem setLabel:@"Replace Tabs "];
        [_removeShredToolbarItem setLabel:@"Remove Tabs "];
    }
    else
    {
        [_addShredToolbarItem setLabel:@"Add Shred"];
        [_replaceShredToolbarItem setLabel:@"Replace Shred"];
        [_removeShredToolbarItem setLabel:@"Remove Shred"];
    }
    
    [super flagsChanged:theEvent];
}


#pragma mark NSKeyValueObserving

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
//    NSLog(@"observeValueForKeyPath %@", keyPath);
    if([keyPath isEqualToString:[NSString stringWithFormat:@"values.%@", mAPreferencesShowTabBar]])
    {
        BOOL show = [[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesShowTabBar];
        [self setShowsTabBar:show];
    }
    else if([keyPath isEqualToString:[NSString stringWithFormat:@"values.%@", mAPreferencesShowToolbar]])
    {
        BOOL show = [[NSUserDefaults standardUserDefaults] boolForKey:mAPreferencesShowToolbar];
        [self setShowsToolbar:show];
    }
    else if([keyPath isEqualToString:@"fileURL"])
    {
        if(object == [self document])
        {
            [[self window] setRepresentedURL:[[self document] fileURL]];
        }
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)vm_on
{
    [self setVMOn:YES];
}

- (void)vm_off
{
    [self setVMOn:NO];
}

- (void)setVMOn:(BOOL)t_vm_on
{
    _vm_on = t_vm_on;
    
    for(NSToolbarItem * item in [[self.window toolbar] items])
    {
        [item setEnabled:_vm_on];
    }
}


#pragma mark OTF toolbar methods

- (void)add:(id)sender
{
    // SPENCERTODO: modifierFlags is apparently 10.6 only
    if([NSEvent respondsToSelector:@selector(modifierFlags)] &&
       ([NSEvent modifierFlags] & NSAlternateKeyMask))
    {
        for(mADocumentViewController *vc in self.contentViewControllers)
            [vc add:sender];
    }
    else
    {
        NSTabViewItem *tabViewItem = [tabView selectedTabViewItem];
        mADocumentViewController *vc = (mADocumentViewController *) tabViewItem.identifier;
        [vc add:sender];
    }
}

- (void)remove:(id)sender
{
    // SPENCERTODO: modifierFlags is apparently 10.6 only
    if([NSEvent respondsToSelector:@selector(modifierFlags)] &&
       ([NSEvent modifierFlags] & NSAlternateKeyMask))
    {
        for(mADocumentViewController *vc in self.contentViewControllers)
            [vc remove:sender];
    }
    else
    {
        NSTabViewItem *tabViewItem = [tabView selectedTabViewItem];
        mADocumentViewController *vc = (mADocumentViewController *) tabViewItem.identifier;
        [vc remove:sender];
    }
}

- (void)replace:(id)sender
{
    // SPENCERTODO: modifierFlags is apparently 10.6 only
    if([NSEvent respondsToSelector:@selector(modifierFlags)] && 
       ([NSEvent modifierFlags] & NSAlternateKeyMask))
    {
        for(mADocumentViewController *vc in self.contentViewControllers)
            [vc replace:sender];
    }
    else
    {
        NSTabViewItem *tabViewItem = [tabView selectedTabViewItem];
        mADocumentViewController *vc = (mADocumentViewController *) tabViewItem.identifier;
        [vc replace:sender];
    }
}

- (void)removeall:(id)sender
{
    NSTabViewItem *tabViewItem = [tabView selectedTabViewItem];
    mADocumentViewController *vc = (mADocumentViewController *) tabViewItem.identifier;
    [vc removeall:sender];
}

- (void)removelast:(id)sender
{
    NSTabViewItem *tabViewItem = [tabView selectedTabViewItem];
    mADocumentViewController *vc = (mADocumentViewController *) tabViewItem.identifier;
    [vc removelast:sender];
}

- (void)clearVM:(id)sender
{
    NSTabViewItem *tabViewItem = [tabView selectedTabViewItem];
    mADocumentViewController *vc = (mADocumentViewController *) tabViewItem.identifier;
    [vc clearVM:sender];
}


- (void)setShowsTabBar:(BOOL)_stb
{
    _showsTabBar = _stb;
    [tabBar setHideForSingleTab:!_showsTabBar];
    [tabBar hideTabBar:(!_showsTabBar && [tabView numberOfTabViewItems] == 1)
                        animate:YES];
}

- (BOOL)showsToolbar
{
    return _showsToolbar;
}

- (void)setShowsToolbar:(BOOL)_stb
{
    _showsToolbar = _stb;
    [_toolbar setVisible:_showsToolbar];
}

- (BOOL)showsTabBar
{
    return _showsTabBar;
}


#pragma mark NSMenuValidation

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
    if([[menuItem title] isEqualToString:@"Close Tab"])
        return [[self window] isKeyWindow];
    else
        return YES;
}


#pragma mark NSToolbarDelegate implementation

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbar_item
{
    if( [toolbar_item tag] == 1 )
    {        
        return _vm_on;
    }
    else
    {
        return YES;
    }
}

- (void)toggleToolbar:(id)sender
{
//    miniAudicleController * mac = [NSDocumentController sharedDocumentController];
//    [mac hideToolbar:sender];
    
    _showsToolbar = !_showsToolbar;
    [_toolbar setVisible:_showsToolbar];
}



@end
