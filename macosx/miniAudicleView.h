/*----------------------------------------------------------------------------
miniAudicle
Cocoa GUI to chuck audio programming environment

Copyright (c) 2005 Spencer Salazar.  All rights reserved.
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

//-----------------------------------------------------------------------------
// file: miniAudicleView.h
// desc: view class for miniAudicle, for displaying ChucK source files
//
// author: Spencer Salazar (ssalazar@princeton.edu)
// date: Autumn 2005
//-----------------------------------------------------------------------------

#ifndef __MINIAUDICLEVIEW_H__
#define __MINIAUDICLEVIEW_H__

#import <Cocoa/Cocoa.h>

#include "chuck_type.h"

@interface miniAudicleView : NSObject
{
    id controller;
    NSTextView * text;
    NSTextField * status_text;
    NSWindow * window;
    
    t_CKINT cid;
    t_CKINT vid;
    NSString * filename;
    NSString * short_filename;
    BOOL vm_on;
}

- (id)initWithFile:(NSString *)file withController:(id)c;
- (void)dealloc;

- (BOOL)save;
- (void)saveAs:(NSString *)file;

- (void)add:(id)sender;
- (void)remove:(id)sender;
- (void)replace:(id)sender;
- (void)removeall:(id)sender;
- (void)removelast:(id)sender;

- (void)vm_on;
- (void)vm_off;

- (void)windowDidBecomeMain:(NSNotification *)n;
- (void)windowWillClose:(NSNotification *)n;
@end

#endif // __MINIAUDICLEVIEW_H__