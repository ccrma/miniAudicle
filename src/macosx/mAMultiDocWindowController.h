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
//  MultiDocWindowController.h
//  MultiDocTest
//
//  Created by Cartwright Samuel on 3/14/13.
//  Copyright (c) 2013 Samuel Cartwright. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PSMTabBarControl/PSMTabBarControl.h"

@interface mAMultiDocWindowController : NSWindowController <NSWindowDelegate, NSToolbarDelegate>
{
    IBOutlet NSTabView *tabView;
	IBOutlet PSMTabBarControl *tabBar;
    
    NSMutableSet* _documents;
    NSMutableSet* _contentViewControllers;
    
    NSToolbar * _toolbar;
    
    BOOL _vm_on;
    BOOL _showsToolbar;
}

- (PSMTabBarControl *)tabBar;

- (IBAction)closeTab:(id)sender;

- (void)addDocument:(NSDocument *)docToAdd;
- (void)removeDocument:(NSDocument *)docToRemove;

- (void)vm_on;
- (void)vm_off;

- (void)add:(id)sender;
- (void)remove:(id)sender;
- (void)replace:(id)sender;
- (void)removeall:(id)sender;
- (void)removelast:(id)sender;

@end
