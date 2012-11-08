/*----------------------------------------------------------------------------
 miniAudicle
 GUI to chuck audio programming environment
 
 Copyright (c) 2008 Spencer Salazar.  All rights reserved.
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
// file: miniAudicle_debug.h
// desc: macros for debugging and tracing
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Spring 2008
//-----------------------------------------------------------------------------

#ifdef __CK_DEBUG__

#else // __CK_DEBUG__

#endif // __CK_DEBUG__

#ifdef __TRACE__

#define trace_location() fprintf(stderr, "at %s (%s:%i)\n", __func__, __FILE__, __LINE__)

#else // __TRACE__

#define trace_location()

#endif // __TRACE__

