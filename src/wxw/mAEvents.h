/*----------------------------------------------------------------------------
miniAudicle
GUI to chuck audio programming environment

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

//-----------------------------------------------------------------------------
// file: mAEvents.h
// desc: miniAudicle wxWidgets event definitions
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

#ifndef __MA_EVENTS_H__
#define __MA_EVENTS_H__

// event IDs
enum
{
    mAID_TOGGLE_VM = wxID_HIGHEST + 1,
    mAID_ADD,
    mAID_REMOVE,
    mAID_REPLACE,
    mAID_ADD_ALL_OPEN_DOCUMENTS,
    mAID_REMOVE_ALL_OPEN_DOCUMENTS,
    mAID_REPLACE_ALL_OPEN_DOCUMENTS,
    mAID_REMOVELAST,
    mAID_REMOVEALL,
    mAID_ABORT_CURRENT_SHRED,
    mAID_VMM_TIMER,
    mAID_UNDO,
    mAID_REDO,
    mAID_CUT,
    mAID_COPY,
    mAID_PASTE,
    mAID_DELETE,
    mAID_SELECTALL,
    mAID_PREFERENCES,
    mAID_SAVE,
    mAID_PARENTFRAME,
    mAID_MINIWEB,
    mAID_CHUCKWEB,
    mAID_LOG,
    mAID_LOG_HIGHEST = mAID_LOG + 10,
    mAID_PREFS_PROBE_AUDIO,
    mAID_PREFS_CHOOSE_FONT,
    mAID_PREFS_SYNTAX_COLORING_ITEM_CHANGED,
    mAID_PREFS_CHOOSE_SYNTAX_COLOR,
    mAID_PREFS_CHOOSE_CWD,
    mAID_PREFS_AUDIO_OUTPUT,
    mAID_PREFS_AUDIO_INPUT,
    mAID_PREFS_CHUGIN_GRID,
    mAID_VIEW_ARGUMENTS_TOGGLE,
    mAID_VIEW_ARGUMENTS_TEXT,
    mAID_WINDOW_VM,
    mAID_WINDOW_CONSOLE /* must be the last id in the list */
};

#endif /* __MA_EVENTS_H__ */


