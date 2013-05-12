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
// file: mAConsoleMonitor.cpp
// desc: console monitor
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

// uncomment following line to stream stderr/stdout as normal
//#define __DISABLE_CONSOLEMONITOR__

#include "chuck_def.h"

#include "wx/wx.h"
#include "wx/config.h"

#include "mAParentFrame.h"
#include "mAConsoleMonitor.h"

#include "chuck_errmsg.h"

#ifndef __PLATFORM_WIN32__
#include <unistd.h>
#include <poll.h>
#include <fcntl.h>
#include <stdio.h>
#else
#include <windows.h>
#include <io.h>
#include <fcntl.h>
#include <stdio.h>
#endif

DECLARE_EVENT_TYPE( mAEVT_CONSOLE_DATA_AVAILABLE, -1 );
DEFINE_EVENT_TYPE( mAEVT_CONSOLE_DATA_AVAILABLE );

#ifdef __LINUX__
mAConsoleMonitor::mAConsoleMonitor( wxWindow * parent, 
    wxWindowID id, const wxString & title, const wxPoint & pos,
    const wxSize & size, long style )
    : wxFrame( parent, id, title, pos, size, style ) 
#else
mAConsoleMonitor::mAConsoleMonitor( wxMDIParentFrame * parent, 
    wxWindowID id, const wxString & title, const wxPoint & pos,
    const wxSize & size, long style )
    : wxMDIChildFrame( parent, id, title, pos, size, style ) 
#endif /* __LINUX__ */

{

#ifdef __LINUX__
    /* GTK specific default positioning for 1280x1024 resolution */
    Maximize( false );
    SetPosition( wxPoint( 20, 575 ) );
#endif

    int x, y, font_size;
    bool maximize;
    wxConfigBase * config = wxConfigBase::Get();
    
    if( config->Read( _T( "/GUI/ConsoleMonitor/width" ), &x ) &&
        config->Read( _T( "/GUI/ConsoleMonitor/height" ), &y ) )
        SetSize( x, y );

    if( config->Read( _T( "/GUI/ConsoleMonitor/x" ), &x ) &&
        config->Read( _T( "/GUI/ConsoleMonitor/y" ), &y ) )
        Move( x, y );
    
    maximize = false;
    if( config->Read( _T( "/GUI/ConsoleMonitor/maximize" ), &maximize ) )
        Maximize( maximize );

    text = new wxTextCtrl( this, wxID_ANY, _T( "" ), wxDefaultPosition, 
        wxDefaultSize, wxTE_MULTILINE | wxTE_READONLY );

    config->Read( _T( "/GUI/ConsoleMonitor/FontSize" ), &font_size, 9 );
    wxFont font( font_size, wxMODERN, wxNORMAL, wxNORMAL );
    text->SetFont( font );

    scrollback_size = 100000;
    config->Read( _T( "/GUI/ConsoleMonitor/ScrollbackBufferSize" ), (int * )&scrollback_size, 100000 );

#ifndef __DISABLE_CONSOLEMONITOR__
    
#ifndef __PLATFORM_WIN32__
    int fd[2];

    if( pipe( fd ) )
    {
        EM_log( CK_LOG_SEVERE, "(console monitor): pipe error, disabling console monitor" );
        return;
    }

    dup2( fd[1], STDOUT_FILENO );

    out_fd = fd[0];

    if( pipe( fd ) )
    {
        EM_log( CK_LOG_SEVERE, "(console monitor): pipe error, disabling console monitor" );
        return;
    }

    dup2( fd[1], STDERR_FILENO );

    err_fd = fd[0];
    
    int fd_flags = fcntl( out_fd, F_GETFL );
    if( fcntl( out_fd, F_SETFL, fd_flags | O_NONBLOCK ) )
    {
        EM_log( CK_LOG_WARNING, "(console monitor): unable to set stdout to non-blocking" );
    }
    
    fd_flags = fcntl( err_fd, F_GETFL );
    if( fcntl( err_fd, F_SETFL, fd_flags | O_NONBLOCK ) )
    {
        EM_log( CK_LOG_WARNING, "(console monitor): unable to set stderr to non-blocking" );
    }
    
    setlinebuf(stdout);
    
#else
    HANDLE hRead, hWrite;
    int fd_read, fd_write;
    //FILE * stdlib_fd;

    if( !CreatePipe( &hRead, &hWrite, NULL, 8192 ) )
    {
        EM_log( CK_LOG_SEVERE, "(console monitor): pipe error %d, disabling console monitor", GetLastError() );
        return;
    }
    
    /* WARNING: Breaks under Win64! */
    fd_read = _open_osfhandle( ( long ) hRead, _O_RDONLY | _O_TEXT );
    fd_write = _open_osfhandle( ( long ) hWrite, _O_WRONLY | _O_TEXT );

    out_fd = fd_read;

    stdlib_fd = _fdopen( fd_write, "w" );

    setvbuf( stdlib_fd, NULL, _IONBF, 0 );
    
    *stderr = *stdlib_fd;
    *stdout = *stdlib_fd;
#endif

    fd_mutex = new XMutex();
    th_go = TRUE;
    th.start( mAConsoleMonitor::callback, this );

    Connect( wxEVT_CLOSE_WINDOW, 
        wxCloseEventHandler( mAConsoleMonitor::OnClose ) );

    Connect( mAEVT_CONSOLE_DATA_AVAILABLE,
        wxCommandEventHandler( mAConsoleMonitor::OnDataAvailable ) );

#ifdef __LINUX__
/*    Connect( wxID_ANY, wxEVT_CHAR, 
        wxCharEventHandler( mAConsoleMonitor::OnChar ) );*/
    menubar = NULL;
#endif

#endif // __DISABLE_CONSOLEMONITOR__
    
    Show( true );
}

mAConsoleMonitor::~mAConsoleMonitor()
{
    SetMenuBar( NULL );

#ifndef __DISABLE_CONSOLEMONITOR__

    th_go = FALSE;

    // close down the fake stdout/stderr so the ConsoleMon thread doesnt hang

    //fd_mutex->release();
    //fclose( stdout );
    
    th.wait();
    
    SAFE_DELETE( fd_mutex );
#endif // __DISABLE_CONSOLEMONITOR__
    
    wxConfigBase * config = wxConfigBase::Get();

    int x, y;

    config->Write( _T( "/GUI/ConsoleMonitor/maximize" ), IsMaximized() );

    if( !IsMaximized() )
    {
        GetSize( &x, &y );
        config->Write( _T( "/GUI/ConsoleMonitor/width" ), x );
        config->Write( _T( "/GUI/ConsoleMonitor/height" ), y );

        GetPosition( &x, &y );
        config->Write( _T( "/GUI/ConsoleMonitor/x" ), x );
        config->Write( _T( "/GUI/ConsoleMonitor/y" ), y );
    }
    
    //SAFE_DELETE( text );
    //close( err_fd );
    //close( out_fd );
}

void mAConsoleMonitor::OnClose( wxCloseEvent & event )
{
    if( event.CanVeto() )
    {
        event.Veto();
        Hide();
    }
    else
        Destroy();
}

#define BUF_SIZE 8192
static char buf[BUF_SIZE];
void mAConsoleMonitor::OnDataAvailable( wxCommandEvent & event )
{
    int len = 0;
    
    text->Freeze();
    
    len = read( event.GetInt(), buf, BUF_SIZE );
    fd_mutex->release();
    
    if( len > 0 )
    {
        buf[len] = 0;
        text->AppendText( wxString( buf, wxConvUTF8 ) );
    }
    
    // chop out the beginning lines if there is too much data
    /*
    // currently disabled, as it slows down liniAudicle waaay too much
    t_CKUINT text_len = text->GetValue().Length();
    if( text_len > scrollback_size )
    {
        t_CKUINT cut = text_len - scrollback_size;
        while( text->GetRange( cut, cut + 1 ) != _T( "\n" ) )
            cut++;
        text->Remove( 0, cut + 1 );
    }*/
    
    text->SetInsertionPointEnd();
    
    text->Thaw();
}

#ifdef __LINUX__
/*
void mAConsoleMonitor::OnChar( wxKeyEvent & event )
{
    event.ResumePropagation( wxEVENT_PROPAGATE_MAX );
    //event.Skip();
    GetParent()->ProcessEvent( event );
    text->SetFocus();
}
*/
/*
void mAConsoleMonitor::SetMenuBar( mAMenuBar * menubar )
{
    if( this->menubar )
    {
        wxGetApp().RemoveMenuBar( menubar );
        PopEventHandler();
        SAFE_DELETE( menubar );
    }
    
    if( menubar )
    {
        this->menubar = menubar;
        PushEventHandler( menubar );
    }
}
*/
#endif

#if defined( __LINUX__ ) || defined( __WINDOWS_PTHREAD__ )
void * mAConsoleMonitor::callback( void * d )
#else
unsigned __stdcall mAConsoleMonitor::callback( void * d )
#endif
{
    if( d == NULL )
        return 0;

    mAConsoleMonitor * console_monitor = ( mAConsoleMonitor * ) d;
    
#ifndef __PLATFORM_WIN32__
    pollfd pfd[2];

    pfd[0].fd = console_monitor->err_fd;
    pfd[0].events = POLLIN;

    pfd[1].fd = console_monitor->out_fd;
    pfd[1].events = POLLIN;

    while( console_monitor->th_go )
    {
        poll( pfd, 2, -1 );
        
        while( poll( pfd, 2, 0 ) > 0 )
        {
            if( pfd[0].revents & POLLIN )
            {
                /* For thread-safety, miniAudicle can only add data to the console 
                   monitor text buffer in the main thread, thus we send the console
                   monitor a wxCommandEvent that tells it to read a specific file
                   descriptor and append any available data to its wxTextCtrl.  The
                   mutex dance that is done here acts as a simple semaphore so that
                   this thread wont start polling again until the main thread is done
                   reading from the file descriptor (it will call release()).   */
                wxCommandEvent event( mAEVT_CONSOLE_DATA_AVAILABLE, pfd[0].fd );
                event.SetInt( pfd[0].fd );
                console_monitor->AddPendingEvent( event );
                console_monitor->fd_mutex->acquire();
            }

            if( pfd[1].revents & POLLIN )
            {
                wxCommandEvent event( mAEVT_CONSOLE_DATA_AVAILABLE, pfd[1].fd );
                event.SetInt( pfd[1].fd );
                console_monitor->AddPendingEvent( event );
                console_monitor->fd_mutex->acquire();
            }
        }
    }

#else
    FILE * f = _fdopen( console_monitor->out_fd, "r" );

    int len = 0;

    while( console_monitor->th_go )
    {       
        buf[0] = 0;

        if( ( len = _read( console_monitor->out_fd, buf, BUF_SIZE ) ) <= 0 )
            break;
        buf[len] = 0;
        console_monitor->text->AppendText( wxString( buf, wxConvUTF8 ) );
/*
        wxString text = console_monitor->text->GetValue();
        t_CKUINT len = text.Length();
        if( len > console_monitor->scrollback_size )
        {
            t_CKUINT cut = len - console_monitor->scrollback_size;
            while( console_monitor->text->GetRange( cut, cut + 1 ) != _T( "\n" ) )
                cut++;
            console_monitor->text->Freeze();
            console_monitor->text->Remove( 0, cut + 2 );
            console_monitor->text->Thaw();
        }
*/
        console_monitor->text->SetInsertionPointEnd();
    }

#endif /* __PLATFORM_WIN32__ */

    return 0;
}

