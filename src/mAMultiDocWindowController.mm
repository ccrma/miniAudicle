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

//
//  MultiDocWindowController.m
//  MultiDocTest
//
//  Created by Cartwright Samuel on 3/14/13.
//  Copyright (c) 2013 Samuel Cartwright. All rights reserved.
//

#import "mAMultiDocWindowController.h"
#import "miniAudicleDocument.h"
#import <PSMTabBarControl/PSMTabStyle.h>

@interface mAMultiDocWindowController ()

@property (nonatomic,retain,readonly) NSMutableSet* documents;
@property (nonatomic,retain,readonly) NSMutableSet* contentViewControllers;

@end

@implementation mAMultiDocWindowController

@synthesize documents = _documents;
@synthesize contentViewControllers = _contentViewControllers;

-(NSMutableSet *)documents {
    if (!_documents) {
        _documents = [[NSMutableSet alloc] initWithCapacity:3];
    }
    return _documents;
}

-(NSMutableSet *)contentViewControllers {
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
        _vm_on = NO;
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [tabBar setHideForSingleTab:NO];
    [tabBar setSizeCellsToFit:YES];
    [tabBar setAllowsResizing:YES];
    [tabBar setAlwaysShowActiveTab:YES];
        
    // add views for any documents that were added before the window was created
    for(NSDocument* document in self.documents) {
        [self addViewWithDocument:document];
    }
    
    _toolbar = [[[NSToolbar alloc] initWithIdentifier:@"miniAudicle"] autorelease];
    [_toolbar setVisible:YES];
    [_toolbar setDelegate:self];

    // add toolbar to the window
    [[self window] setToolbar:_toolbar];

    NSButton * toolbar_pill = [[self window] standardWindowButton:NSWindowToolbarButton];
    [toolbar_pill setTarget:self];
    [toolbar_pill setAction:@selector(toggleToolbar:)];
    
    [tabBar setStyleNamed:@"Unified"];
}

-(void)addViewWithDocument:(NSDocument*) document {
    
    if ([document respondsToSelector:@selector(newPrimaryViewController)]) {
        NSViewController* addedCtrl = [(id)document newPrimaryViewController];
        [self.contentViewControllers addObject: addedCtrl];
        
        NSTabViewItem* tabViewItem = [[[NSTabViewItem alloc]initWithIdentifier: addedCtrl] autorelease];
        [tabViewItem setView: addedCtrl.view];
        [tabViewItem setLabel: [document displayName]];
        
        NSUInteger tabIndex = [tabView numberOfTabViewItems];
        [tabView insertTabViewItem:tabViewItem atIndex:tabIndex];
        [tabView selectTabViewItem: tabViewItem];
        
        [document setWindow: self.window];
    }
    
    [document addWindowController:self];
}

-(void)addDocument:(NSDocument *)docToAdd
{
    NSMutableSet* documents = self.documents;
    if ([documents containsObject:docToAdd]) {
        return;
    }
    
    [documents addObject:docToAdd];

    // check if the window has been created. We can not insert new tab
    // items until the nib has been loaded. So if the window isnt created
    // yet, do nothing and instead add the view controls during the
    // windowDidLoad function
    
    if(self.isWindowLoaded) {
        [self addViewWithDocument:docToAdd];
    }
}

-(void)removeDocument:(NSDocument *)docToRemove attachedToViewController:(NSViewController*)ctrl
{
    NSMutableSet* documents = self.documents;
    if (![documents containsObject:docToRemove]) {
        return;
    }
    
    // remove the document's view controller and view
    [ctrl.view removeFromSuperview];
    if ([ctrl respondsToSelector:@selector(setDocument:)]) {
        [(id)ctrl setDocument: nil];
    }
    [ctrl release];
    
        // remove the view from the tab item
        // dont remove the tab view item from the tab view, as this is handled by the framework (when
        // we click on the close button on the tab) - of course it wouldnt be if you closed the document
        // using the menu (TODO)
    NSTabViewItem* tabViewItem = [tabView tabViewItemAtIndex: [tabView indexOfTabViewItemWithIdentifier: ctrl]];
    [tabViewItem setView: nil];
    
        // remove the control from the view controllers set
    [self.contentViewControllers removeObject: ctrl];
    
    // finally detach the document from the window controller
    [docToRemove removeWindowController:self];
    [documents removeObject:docToRemove];
}

-(void)setDocument:(NSDocument *)document
{
    // NSLog(@"Will not set document to: %@",document);
}

- (BOOL)tabView:(NSTabView *)aTabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem {
    return TRUE;
}

- (void)tabView:(NSTabView *)aTabView willCloseTabViewItem:(NSTabViewItem *)tabViewItem {
    NSLog(@"Will Close Tab View Item");
    
    // identifier is wrong now
    NSViewController* ctrl = (NSViewController*)[[tabView selectedTabViewItem] identifier];
    
    if ([ctrl respondsToSelector:@selector(document)]) {
        NSDocument* doc = [(id) ctrl document];
        [self removeDocument:doc attachedToViewController:ctrl];
    }
}

- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem {
    NSLog(@"Did Close Tab View Item");    
}

- (void)tabView:(NSTabView *)aTabView didDetachTabViewItem:(NSTabViewItem *)tabViewItem {
    NSLog(@"Did Detach Tab View Item");    
}

-(NSDocument*)document
{
    NSTabViewItem *tabViewItem = [tabView selectedTabViewItem];
    NSViewController* ctrl = (NSViewController*)tabViewItem.identifier;
    
    if ([ctrl respondsToSelector:@selector(document)]) {
        return [(id) ctrl document];
    }
    return nil;
}

// Each document needs to be detached from the window controller before the window closes.
// In addition, any references to those documents from any child view controllers will also
// need to be cleared in order to ensure a proper cleanup.
// The windowWillClose: method does just that. One caveat found during debugging was that the
// window controller’s self pointer may become invalidated at any time within the method as
// soon as nothing else refers to it (using ARC). Since we’re disconnecting references to
// documents, there have been cases where the window controller got deallocated mid-way of
// cleanup. To prevent that, I’ve added a strong pointer to self and use that pointer exclusively
// in the windowWillClose: method.
-(void) windowWillClose:(NSNotification *)notification
{
    NSWindow * window = self.window;
    if (notification.object != window) {
        return;
    }
    
    // let's keep a reference to ourself and not have us thrown away while we clear out references.
    mAMultiDocWindowController* me = self;

    // detach the view controllers from the document first
    for (NSViewController* ctrl in me.contentViewControllers) {
        [ctrl.view removeFromSuperview];
        if ([ctrl respondsToSelector:@selector(setDocument:)]) {
            [(id) ctrl setDocument:nil];
            [ctrl release];
        }
    }
    
    // then any content view
    [window setContentView:nil];
    [me.contentViewControllers removeAllObjects];
       
    // disassociate this window controller from the document
    for (NSDocument* doc in me.documents) {
        [doc removeWindowController:me];
    }
    [me.documents removeAllObjects];
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
    
    NSArray * toolbar_items = [_toolbar items];
    
    int i = 0, len = [toolbar_items count];
    for( ; i < len; i++ )
    {
        [[toolbar_items objectAtIndex:i] setEnabled:_vm_on];
    }
}

#pragma mark NSToolbar stuff

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
     itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem * toolbar_item;
    
    if( [itemIdentifier isEqual:@"add"] )
    {
        toolbar_item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbar_item setLabel:@"Add Shred"];
        [toolbar_item setAction:@selector(add:)];
        [toolbar_item setImage:[NSImage imageNamed:@"add.png"]];
    }
    
    else if( [itemIdentifier isEqual:@"remove"] )
    {
        toolbar_item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbar_item setLabel:@"Remove Shred"];
        [toolbar_item setAction:@selector(remove:)];
        [toolbar_item setImage:[NSImage imageNamed:@"remove.png"]];
    }
    
    else if( [itemIdentifier isEqual:@"replace"] )
    {
        toolbar_item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbar_item setLabel:@"Replace Shred"];
        [toolbar_item setAction:@selector(replace:)];
        [toolbar_item setImage:[NSImage imageNamed:@"replace.png"]];
    }
    
    else if( [itemIdentifier isEqual:@"removeall"] )
    {
        toolbar_item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbar_item setLabel:@"Remove All Shreds"];
        [toolbar_item setAction:@selector(removeall:)];
        [toolbar_item setImage:[NSImage imageNamed:@"removeall.png"]];
    }
    
    else if( [itemIdentifier isEqual:@"removelast"] )
    {
        toolbar_item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        [toolbar_item setLabel:@"Remove Last Shred"];
        [toolbar_item setAction:@selector(removelast:)];
        [toolbar_item setImage:[NSImage imageNamed:@"removelast.png"]];
    }
    
    [toolbar_item autorelease];
    
    [toolbar_item setEnabled:_vm_on];
    
    [toolbar_item setTag:1];
    [toolbar_item setTarget:self];
    
    return toolbar_item;
}

- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:@"add", @"remove", @"removelast",
            @"removeall", NSToolbarFlexibleSpaceItemIdentifier, @"replace", nil];
}

- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects:@"add", @"replace", @"remove",
            NSToolbarFlexibleSpaceItemIdentifier, @"removelast", @"removeall", nil];
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbar_item
{
    if( [toolbar_item tag] == 1 )
        return _vm_on;
    
    else
        return YES;
}

- (void)toggleToolbar:(id)sender
{
//    miniAudicleController * mac = [NSDocumentController sharedDocumentController];
//    [mac hideToolbar:sender];
    
    _showsToolbar = !_showsToolbar;
    [_toolbar setVisible:_showsToolbar];
}



@end
