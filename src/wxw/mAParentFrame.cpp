/*----------------------------------------------------------------------------
miniAudicle
GUI to chuck audio programming environment

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
// file: mAParentWindow.cpp
// desc: wxWidgets MDI Parent window
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

#include "chuck_def.h"

#include "wx/wx.h" //use precompiled headers?
#include "wx/utils.h"
#include "wx/image.h"
#include "wx/config.h"
#if wxCHECK_VERSION( 2, 8, 0 )
#include "wx/filename.h"
#endif // wxCHECK_VERSION( 2, 8, 0 )

#include "mAParentFrame.h"
#include "mADocument.h"
#include "mAView.h"
#include "mAEvents.h"
#include "mAConfig.h"

#include "digiio_rtaudio.h"

#ifdef __LINUX__
#include "icons/add.xpm"
#include "icons/remove.xpm"
#include "icons/replace.xpm"
#endif

#include "icons/miniAudicle.xpm"

extern const char MA_VERSION[];
extern const char MA_ABOUT[];
extern const char MA_HELP[];
extern const char CK_VERSION[];

IMPLEMENT_APP( mAApp )

mAApp::mAApp()
{
    parent_frame = NULL;
    doc_manager = NULL;
    vm_monitor = NULL;
    console_monitor = NULL;
    ma = NULL;
    vm_on = FALSE;
    in_lockdown = FALSE;
}

bool mAApp::OnInit()
{
    setlocale( LC_ALL, "C" );
    wxConfigBase * config = new mAConfig();
    wxConfigBase::Set( config );
    config->SetRecordDefaults();
    
    doc_manager = new wxDocManager;
    ma = new miniAudicle;
    
    parent_frame = new mAParentFrame( ma, doc_manager, NULL, 
        _T( "miniAudicle" ), wxPoint( 0, 0 ), wxSize( 800, 600 ), 
        wxDEFAULT_FRAME_STYLE | wxNO_FULL_REPAINT_ON_RESIZE | wxMAXIMIZE | wxFRAME_NO_WINDOW_MENU );

    (void) new wxDocTemplate( doc_manager, _T("ChucK Source File"), _T("*.ck"), _T(""), _T("ck"), 
        _T("ChucK Source File"), _T("ChucK Source View"), 
        CLASSINFO( mAChuckDocument ), CLASSINFO( mAChuckView ) );

    mAMenuBar * menu_bar = new mAMenuBar;
    doc_manager->FileHistoryUseMenu( menu_bar->GetFileHistoryMenu() );
    menu_bars.push_front( menu_bar );

    parent_frame->SetMenuBar( menu_bar );

    LoadCommandLineArguments();
    
#ifdef __WINDOWS_DS__
    parent_frame->SetIcon( wxIcon( _T( "miniAudicle" ) ) );
#else
    parent_frame->SetIcon( wxIcon( miniAudicle_xpm ) );
#endif

    parent_frame->Centre( wxBOTH );

    vm_monitor = new mAVMMonitor( ma, parent_frame, mAID_PARENTFRAME, 
        _T( "" ), wxPoint( 655, 20 ), wxSize( 270, 400 ), 
        wxDEFAULT_FRAME_STYLE );
    window_menu_map[mAID_WINDOW_VM] = vm_monitor;
#ifndef __LINUX__
    /* liniAudicle uses a separate non-MDI window for the vm monitor, which
       doesnt need its own menu bar */
    menu_bar = new mAMenuBar;
    doc_manager->FileHistoryUseMenu( menu_bar->GetFileHistoryMenu() );
    vm_monitor->SetMenuBar( menu_bar );
    vm_monitor->SetIcon( wxIcon( _T( "miniAudicle" ) ) );
    menu_bars.push_front( menu_bar );
#else
    vm_monitor->SetIcon( wxIcon( miniAudicle_xpm ) );
#endif

    console_monitor = new mAConsoleMonitor( parent_frame, wxID_ANY,
        _T( "Console Monitor" ), wxPoint( 40, 580 ), wxSize( 550, 350 ) );
    window_menu_map[mAID_WINDOW_CONSOLE] = console_monitor;
#ifndef __LINUX__
    /* liniAudicle uses separate non-MDI window for the console monitor, 
       which doesnt need its own menu bar */
    menu_bar = new mAMenuBar;
    doc_manager->FileHistoryUseMenu( menu_bar->GetFileHistoryMenu() );
    console_monitor->SetMenuBar( menu_bar );
    console_monitor->SetIcon( wxIcon( _T( "miniAudicle" ) ) );
    menu_bars.push_front( menu_bar );
#else
    console_monitor->SetIcon( wxIcon( miniAudicle_xpm ) );
#endif

    preferences_window = new mAPreferencesWindow( ma, parent_frame );
#ifndef __LINUX__
    /* liniAudicle uses separate non-MDI window for the preferences window, 
       which doesnt need its own menu bar */
    menu_bar = new mAMenuBar;
    doc_manager->FileHistoryUseMenu( menu_bar->GetFileHistoryMenu() );
    preferences_window->SetMenuBar( menu_bar );
    preferences_window->SetIcon( wxIcon( _T( "miniAudicle" ) ) );
    menu_bars.push_front( menu_bar );
#else
    preferences_window->SetIcon( wxIcon( miniAudicle_xpm ) );
#endif

#ifdef __LINUX__
    wxToolBar * toolbar = parent_frame->CreateToolBar( wxTB_HORIZONTAL | 
                                                       wxTB_TEXT | 
                                                       wxTB_DOCKABLE );
    wxSize bitmap_size( 32, 32 );
    toolbar->SetToolBitmapSize( bitmap_size );

    wxBitmap add_bitmap( add_xpm );
    toolbar->AddTool( mAID_ADD, _T( "Add Shred" ), add_bitmap );

    toolbar->AddSeparator();

    wxBitmap replace_bitmap( replace_xpm );
    toolbar->AddTool( mAID_REPLACE, _T( "Replace Shred" ), replace_bitmap );
    
    toolbar->AddSeparator();

    wxBitmap remove_bitmap( remove_xpm );
    toolbar->AddTool( mAID_REMOVE, _T( "Remove Shred" ), remove_bitmap );

    toolbar->Realize();
    
    toolbar->EnableTool( mAID_ADD, false );
    toolbar->EnableTool( mAID_REMOVE, false );
    toolbar->EnableTool( mAID_REPLACE, false );
    
#endif

    LoadPreferences();

    Connect( mAID_LOG, mAID_LOG_HIGHEST, wxEVT_COMMAND_MENU_SELECTED,
        wxCommandEventHandler( mAApp::OnLogLevel ) );
    Connect( mAID_ABORT_CURRENT_SHRED, wxEVT_COMMAND_MENU_SELECTED,
        wxCommandEventHandler( mAApp::OnAbortCurrentShred ) );
    Connect( mAID_PREFERENCES, wxEVT_COMMAND_MENU_SELECTED,
        wxCommandEventHandler( mAApp::OnPreferencesCommand ) );
    Connect( mAID_WINDOW_VM, wxEVT_COMMAND_MENU_SELECTED,
        wxCommandEventHandler( mAApp::OnWindowCommand ) );
    Connect( mAID_WINDOW_CONSOLE, wxEVT_COMMAND_MENU_SELECTED,
        wxCommandEventHandler( mAApp::OnWindowCommand ) );
    Connect( wxID_ANY, wxEVT_CHAR, 
        wxCharEventHandler( mAApp::OnChar ) );

    parent_frame->Show( true );

    if( doc_manager->GetDocuments().GetCount() == 0 )
        doc_manager->CreateDocument( _T( "" ), wxDOC_NEW );
    SetTopWindow( parent_frame );
    
    return true;
}

void mAApp::LoadCommandLineArguments()
{
    int i;
    wxString key, value;
    long l;
    mAConfig * config = ( mAConfig * ) wxConfigBase::Get();
    
    for( i = 1; i < argc; i++ )
    {
        key = argv[i];
        
        if( key.StartsWith( _T( "--bufsize" ), &value ) ||
            key.StartsWith( _T( "-b" ), &value ) )
        {
            if( value.ToLong( &l ) )
                config->WriteCommandLineArgument( _T( "/VM/SampleBufferSize" ), l );
        }
        
        else if( key.StartsWith( _T( "--srate" ), &value ) ||
                 key.StartsWith( _T( "-r" ), &value ) )
        {
            if( value.ToLong( &l ) )
                config->WriteCommandLineArgument( _T( "/VM/SampleRate" ), l );
        }
        
        else if( key.StartsWith( _T( "--bufnum" ), &value ) ||
                 key.StartsWith( _T( "-n" ), &value ) )
        {
            if( value.ToLong( &l ) )
            {
            }
        }
        
        else if( key.StartsWith( _T( "--channels" ), &value ) ||
                 key.StartsWith( _T( "-c" ), &value ) )
        {
            if( value.ToLong( &l ) )
            {
                config->WriteCommandLineArgument( _T( "/VM/InputChannels" ), l );
                config->WriteCommandLineArgument( _T( "/VM/OutputChannels" ), l );
            }
        }
        
        else if( key.StartsWith( _T( "--in" ), &value ) ||
                 key.StartsWith( _T( "-i" ), &value ) )
        {
            if( value.ToLong( &l ) )
                config->WriteCommandLineArgument( _T( "/VM/InputChannels" ), l );
        }
        
        else if( key.StartsWith( _T( "--out" ), &value ) ||
                 key.StartsWith( _T( "-o" ), &value ) )
        {
            if( value.ToLong( &l ) )
                config->WriteCommandLineArgument( _T( "/VM/OutputChannels" ), l );
        }
        
        else if( key.StartsWith( _T( "--adc" ), &value ) )
        {
            if( value.ToLong( &l ) )
                config->WriteCommandLineArgument( _T( "/VM/ADC" ), l );
        }
        
        else if( key.StartsWith( _T( "--dac" ), &value ) )
        {
            if( value.ToLong( &l ) )
                config->WriteCommandLineArgument( _T( "/VM/DAC" ), l );
        }
        
        else if( key.StartsWith( _T( "--help" ), NULL ) || 
                 key.StartsWith( _T( "--about" ), NULL ) )
        {
            fprintf( stderr, MA_HELP, MA_VERSION, CK_VERSION );
            exit( 0 );
        }
        
        else if( key.StartsWith( _T( "--verbose" ), &value ) || 
                 key.StartsWith( _T( "-v" ), &value ) )
        {
            if( value.ToLong( &l ) )
                config->WriteCommandLineArgument( _T( "/VM/LogLevel" ), l );
        }
        
        else if( key.StartsWith( _T( "--probe" ), NULL ) )
        {
            Digitalio::probe();
            exit( 0 );
        }
        
        else
        /* assuming everything else is a file */
            break;
    }
    
    for( ; i < argc; i++ )
    {
        doc_manager->CreateDocument( argv[i], wxDOC_SILENT );
    }
}

void mAApp::LoadPreferences()
{
    SetAppName( _T( "miniAudicle" ) );

    mAConfig * config = ( mAConfig * ) wxConfigBase::Get();

    int x, y;
    bool maximize = true;

    if( config->Read( mAPreferencesParentFrameWidth, &x ) &&
        config->Read( mAPreferencesParentFrameHeight, &y ) )
        parent_frame->SetSize( x, y );

    if( config->Read( mAPreferencesParentFrameX, &x ) &&
        config->Read( mAPreferencesParentFrameY, &y ) )
        parent_frame->Move( x, y );

#ifdef __LINUX__
    config->Read( mAPreferencesParentFrameMaximize, &maximize, false );
#else
    config->Read( mAPreferencesParentFrameMaximize, &maximize, true );
#endif
    parent_frame->Maximize( maximize );

    if( config->Read( _T( "/GUI/VMMonitor/width" ), &x ) &&
        config->Read( _T( "/GUI/VMMonitor/height" ), &y ) )
        vm_monitor->SetSize( x, y );

    if( config->Read( _T( "/GUI/VMMonitor/x" ), &x ) &&
        config->Read( _T( "/GUI/VMMonitor/y" ), &y ) )
        vm_monitor->Move( x, y );

    if( config->Read( _T( "/GUI/VMMonitor/maximize" ), &maximize, false ) )
        vm_monitor->Maximize( maximize );
    
    int log_level;
    config->Read( _T( "/VM/LogLevel" ), &log_level, 2 );
    ma->set_log_level( log_level ); 
    std::list< mAMenuBar * >::iterator i = menu_bars.begin(),
        end = menu_bars.end();
    for( ; i != end; i++ )
        (*i)->SetLogLevel( log_level );
    
    long l;
    
    if( config->Read( mAPreferencesAudioOutput, &l, 0 ) )
        ma->set_dac( ( int ) l );

    if( config->Read( mAPreferencesAudioInput, &l, 0 ) )
        ma->set_adc( ( int ) l );

    if( config->Read( mAPreferencesSampleRate, &l, ma->get_sample_rate() ) )
    {
        ma->set_sample_rate( ( int ) l );
    }

    if( config->Read( mAPreferencesInputChannels, &l, 2 ) )
        ma->set_num_inputs( ( int ) l );

    if( config->Read( mAPreferencesOutputChannels, &l, 2 ) )
        ma->set_num_outputs( ( int ) l );

    if( config->Read( mAPreferencesBufferSize, &l, ma->get_buffer_size() ) )
        ma->set_buffer_size( ( int ) l );

    wxString str = wxGetHomeDir();
    if( config->Read( mAPreferencesCurrentDirectory, &str, wxGetHomeDir() ) )
        wxSetWorkingDirectory( str );

    doc_manager->FileHistoryLoad( *config );
}

void mAApp::SavePreferences()
{
    wxConfigBase * config = wxConfigBase::Get();

    doc_manager->FileHistorySave( *config );
    
    delete config;
}

void mAApp::OnAbortCurrentShred( wxCommandEvent & event )
{
    ma->abort_current_shred();
}

void mAApp::OnLogLevel( wxCommandEvent & event )
{
    ma->set_log_level( event.GetId() - mAID_LOG );
    
    int log_level = ma->get_log_level();
    
    wxConfigBase::Get()->Write( _T( "/VM/LogLevel" ), log_level );

    std::list< mAMenuBar * >::iterator i = menu_bars.begin(),
        end = menu_bars.end();
    for( ; i != end; i++ )
        (*i)->SetLogLevel( log_level );
}

void mAApp::OnPreferencesCommand( wxCommandEvent & event )
{
    preferences_window->OnPreferencesCommand( event );
}

void mAApp::OnWindowCommand( wxCommandEvent & event )
{
    mAFrameType * frame = window_menu_map[event.GetId()];

    if( ( frame == console_monitor || frame == vm_monitor )
#ifdef __WINDOWS_DS__
        && frame == parent_frame->GetActiveChild() )
#else
        && frame->IsActive() )
#endif
    {
        frame->Close();
#ifdef __WINDOWS_DS__
        parent_frame->ActivateNext();
#endif
    }

    else
    {
        frame->Show();

        if( frame->IsIconized() )
            frame->Restore();
#ifdef __WINDOWS_DS__
        frame->Activate();
#else
        if( frame != console_monitor && frame != vm_monitor )
            ( ( wxDocMDIChildFrame * ) frame )->Activate();
        else
            frame->Raise();
#endif
    }
}

void mAApp::OnChar( wxKeyEvent & event )
{
    //fprintf( stderr, "here\n" );
    // handle hacked non-alphanumeric accelerators
    if( event.AltDown() )
    {
        int key = event.GetKeyCode();

        if( key == '.' && !vm_on )
        {
            wxCommandEvent cmd_event( wxEVT_COMMAND_MENU_SELECTED, 
                mAID_TOGGLE_VM );
            parent_frame->ProcessEvent( cmd_event );
        }
        
        else if( key == '+' )
        {
            wxCommandEvent cmd_event( wxEVT_COMMAND_MENU_SELECTED, 
                mAID_ADD );
            parent_frame->ProcessEvent( cmd_event );
        }

        else if( key == '-' )
        {
            wxCommandEvent cmd_event( wxEVT_COMMAND_MENU_SELECTED, 
                mAID_REMOVE );
            parent_frame->ProcessEvent( cmd_event );
        }
        
        else if( key == '=' )
        {
            wxCommandEvent cmd_event( wxEVT_COMMAND_MENU_SELECTED, 
                mAID_REPLACE );
            parent_frame->ProcessEvent( cmd_event );
        }
        
        else if( key == ',' )
        {
            wxCommandEvent cmd_event( wxEVT_COMMAND_MENU_SELECTED,
                mAID_PREFERENCES );
            parent_frame->ProcessEvent( cmd_event );
        }

        else
            event.Skip();
    }

    else
        event.Skip();
}

t_CKBOOL mAApp::IsInLockdown()
{
    return in_lockdown;
}

void mAApp::SetLockdown( t_CKBOOL lockdown )
{
    if( lockdown && !in_lockdown )
    {
        in_lockdown = lockdown;

        int return_code = wxMessageBox( _T( "The Virtual Machine appears to be hanging.  This is typically caused by a shred running in an infinite loop, or it may simply be a shred performing a finite amount of heavy processing.  If you would like to abort the current shred and unhang the virtual machine, click \"Yes.\"  To leave the current shred running, click \"No.\"  If you choose to leave the current shred running, execution of on-the-fly programming commands may be delayed.\n\nWould you like to abort the current shred?" ), 
                                        _T( "Abort current shred" ), 
                                        wxYES_NO | wxICON_EXCLAMATION, 
                                        parent_frame );
        if( return_code == wxYES )
            ma->abort_current_shred();
    }
    
    else
        in_lockdown = lockdown;
}

void mAApp::RemoveMenuBar( mAMenuBar * menu_bar )
{
    doc_manager->FileHistoryRemoveMenu( menu_bar->GetFileHistoryMenu() );
    menu_bars.remove( menu_bar );
}

void mAApp::RemoveView( mAChuckView * view )
{
    views.remove( view );
}

int mAApp::AddWindowMenuItem( mAFrameType * frame )
{
    int id;

    const wxString & title = frame->GetTitle();

    std::list< mAMenuBar * >::iterator i = menu_bars.begin(),
        end = menu_bars.end();
    for( ; i != end; i++ )
        id = (*i)->AddWindow( title );

    window_menu_map[id] = frame;

    Connect( id, wxEVT_COMMAND_MENU_SELECTED,
        wxCommandEventHandler( mAApp::OnWindowCommand ) );

    return id;
}

void mAApp::ChangeWindowMenuItem( int id )
{
    const wxString & title = window_menu_map[id]->GetTitle();

    std::list< mAMenuBar * >::iterator i = menu_bars.begin(),
        end = menu_bars.end();
    for( ; i != end; i++ )
        (*i)->ChangeWindow( id, title );
}

void mAApp::RemoveWindowMenuItem( int id )
{
    Disconnect( id, wxEVT_COMMAND_MENU_SELECTED );

    window_menu_map.erase( id );

    std::list< mAMenuBar * >::iterator i = menu_bars.begin(),
        end = menu_bars.end();
    for( ; i != end; i++ )
        (*i)->RemoveWindow( id );
}

mADocMDIChildFrame * mAApp::CreateChildFrame( wxDocument * doc, 
                                              mAChuckView * view )
{
#ifndef __LINUX__
    mADocMDIChildFrame * subframe = new mADocMDIChildFrame( doc, view, 
        parent_frame, wxID_ANY, _T("Child Frame"), wxPoint( 10, 10 ), 
        wxSize( 500, 500 ), 
        wxDEFAULT_FRAME_STYLE | wxNO_FULL_REPAINT_ON_RESIZE | wxCAPTION );
#else
    /* On Linux/GTK, use the default position and size since we cant choose
       that anyway.  If we try to specify a non-default size, the 
       wxStyledTextCtrl gets messed up during resizes.  */
    mADocMDIChildFrame * subframe = new mADocMDIChildFrame( doc, view, 
        parent_frame, wxID_ANY, _T( "Child Frame" ), wxPoint( -1, -1 ), 
        wxSize( -1, -1 ), 
        wxDEFAULT_FRAME_STYLE | wxNO_FULL_REPAINT_ON_RESIZE | wxCAPTION );
#endif

    /* Apparently every frame needs to have its own menubar.  Sounds
    pretty braindead to me.  */
    mAMenuBar * menu_bar = new mAMenuBar;
    doc_manager->FileHistoryUseMenu( menu_bar->GetFileHistoryMenu() );
    doc_manager->FileHistoryAddFilesToMenu( menu_bar->GetFileHistoryMenu() );
    if( vm_on )
        /* enable the ChucK menu items that are greyed out by default */
        menu_bar->OnVMStart();
    menu_bar->SetLogLevel( ma->get_log_level() );
    menu_bar->SynchronizeWindowMenuTo( menu_bars.front() );
    menu_bars.push_front( menu_bar );
    
    subframe->SetMenuBar( menu_bar );
    
#ifdef __LINUX__
    subframe->SetIcon( wxIcon( miniAudicle_xpm ) );
#else
    subframe->SetIcon( wxIcon( "miniAudicle" ) );
#endif
    /*
#if wxCHECK_VERSION( 2, 8, 0 ) && 0
    wxString title = doc->GetFilename();
    if( title == _T( "" ) )
        doc_manager->MakeDefaultName( title );
    else
        title = wxFileName( title ).GetFullName();
    subframe->SetTitle( title );
#endif // wxCHECK_VERSION( 2, 8, 0 )
*/
    view->SetMiniAudicle( ma );
    
    views.push_front( view );

    return subframe;
}

mAFrameType * mAApp::CreateChildFrame( wxWindowID id )
{
    mAFrameType * subframe = new mAFrameType( parent_frame, id, _T( "" ), 
        wxDefaultPosition, wxDefaultSize, 
        wxDEFAULT_FRAME_STYLE & ~( wxRESIZE_BORDER | wxRESIZE_BOX | wxMAXIMIZE_BOX ) );

#ifndef __LINUX__
    /* Apparently every frame needs to have its own menubar.  Sounds
    pretty braindead to me.  */
    mAMenuBar * menu_bar = new mAMenuBar;
    doc_manager->FileHistoryUseMenu( menu_bar->GetFileHistoryMenu() );
    doc_manager->FileHistoryAddFilesToMenu( menu_bar->GetFileHistoryMenu() );
    if( vm_on )
        /* enable the ChucK menu items that are greyed out by default */
        menu_bar->OnVMStart();
    menu_bar->SetLogLevel( ma->get_log_level() );
    menu_bar->SynchronizeWindowMenuTo( menu_bars.front() );
    menu_bars.push_front( menu_bar );
    
    subframe->SetMenuBar( menu_bar );
#endif
    
#ifdef __WINDOWS_DS__
    subframe->SetIcon( wxIcon( _T( "miniAudicle" ) ) );
#else
    subframe->SetIcon( wxIcon( miniAudicle_xpm ) );
#endif

    return subframe;
}

void mAApp::OnVMStart()
{
    std::list< mAMenuBar * >::iterator i = menu_bars.begin(),
        end = menu_bars.end();
    for( ; i != end; i++ )
        (*i)->OnVMStart();

    vm_monitor->OnVMStart();
    vm_on = TRUE;

#ifdef __LINUX__
    wxToolBar * toolbar = parent_frame->GetToolBar();
    toolbar->EnableTool( mAID_ADD, true );
    toolbar->EnableTool( mAID_REMOVE, true );
    toolbar->EnableTool( mAID_REPLACE, true );
#else
    std::list< mAChuckView * >::iterator j = views.begin(),
        jend = views.end();
    for( ; j != jend; j++ )
        (*j)->OnVMStart();    
#endif
}

void mAApp::OnVMStop()
{
    std::list< mAMenuBar * >::iterator i = menu_bars.begin(),
        end = menu_bars.end();
    for( ; i != end; i++ )
        (*i)->OnVMStop();

    vm_monitor->OnVMStop();
    vm_on = FALSE;
    
#ifdef __LINUX__
    wxToolBar * toolbar = parent_frame->GetToolBar();
    toolbar->EnableTool( mAID_ADD, false );
    toolbar->EnableTool( mAID_REMOVE, false );
    toolbar->EnableTool( mAID_REPLACE, false );
#else
    std::list< mAChuckView * >::iterator j = views.begin(),
        jend = views.end();
    for( ; j != jend; j++ )
        (*j)->OnVMStop();   
#endif
}

void mAApp::EditingPreferencesChanged()
{
    std::list< mAChuckView * >::iterator j = views.begin(),
        jend = views.end();
    for( ; j != jend; j++ )
        (*j)->EditingPreferencesChanged();  
}

void mAApp::SyntaxColoringPreferencesChanged()
{
    std::list< mAChuckView * >::iterator j = views.begin(),
        jend = views.end();
    for( ; j != jend; j++ )
        (*j)->SyntaxColoringPreferencesChanged();   
}

int mAApp::OnExit()
{
    // this function is apparently never called

    SavePreferences();
#if !defined( __WINDOWS_DS__ )
    SAFE_DELETE( ma );
#endif
    SAFE_DELETE( doc_manager );

    return 0;
}

IMPLEMENT_CLASS( mAParentFrame, wxDocMDIParentFrame )
BEGIN_EVENT_TABLE( mAParentFrame, wxDocMDIParentFrame )
    EVT_MENU( mAID_TOGGLE_VM, mAParentFrame::OnToggleVM )
    EVT_MENU( mAID_ADD, mAParentFrame::OnAdd )
    EVT_MENU( mAID_REMOVE, mAParentFrame::OnRemove )
    EVT_MENU( mAID_REPLACE, mAParentFrame::OnReplace )

    EVT_MENU( mAID_ADD_ALL_OPEN_DOCUMENTS, mAParentFrame::OnAddAllOpenDocuments )
    EVT_MENU( mAID_REMOVE_ALL_OPEN_DOCUMENTS, mAParentFrame::OnRemoveAllOpenDocuments )
    EVT_MENU( mAID_REPLACE_ALL_OPEN_DOCUMENTS, mAParentFrame::OnReplaceAllOpenDocuments )

    EVT_MENU( mAID_REMOVELAST, mAParentFrame::OnRemovelast )
    EVT_MENU( mAID_REMOVEALL, mAParentFrame::OnRemoveall )

    EVT_MENU( mAID_UNDO, mAParentFrame::OnEditMenu )
    EVT_MENU( mAID_REDO, mAParentFrame::OnEditMenu )
    EVT_MENU( mAID_CUT, mAParentFrame::OnEditMenu )
    EVT_MENU( mAID_COPY, mAParentFrame::OnEditMenu )
    EVT_MENU( mAID_PASTE, mAParentFrame::OnEditMenu )
    EVT_MENU( mAID_DELETE, mAParentFrame::OnEditMenu )
    EVT_MENU( mAID_SELECTALL, mAParentFrame::OnEditMenu )

    EVT_MENU( mAID_MINIWEB, mAParentFrame::OnMiniWeb )
    EVT_MENU( mAID_CHUCKWEB, mAParentFrame::OnChucKWeb )
    EVT_MENU( wxID_ABOUT, mAParentFrame::OnAbout )
    
    EVT_BUTTON( mAID_TOGGLE_VM, mAParentFrame::OnToggleVM )
    
    EVT_CLOSE( mAParentFrame::OnCloseWindow )
END_EVENT_TABLE()


mAParentFrame::mAParentFrame( miniAudicle * ma,
                              wxDocManager * manager, wxFrame * frame, 
                              const wxString & title, const wxPoint& pos, 
                              const wxSize & size, long type ) 
    : wxDocMDIParentFrame( manager, frame, wxID_ANY, title, pos, size, type, _T("mAFrame") )
{
#ifdef __LINUX__
    /* Linux-specific default positioning for 1280x1024 resolution */
    Maximize( false );
    SetSize( wxSize( 570, 550 ) );
#endif

    this->ma = ma;
    vm_on = false;
    docid = ma->allocate_document_id();

    // construct the about... dialog
    about_dialog.Create( this, wxID_ANY, _T( "miniAudicle" ), wxPoint( -1, -1 ),
        wxSize( 300, 325 ), wxDEFAULT_DIALOG_STYLE /*& ( ~wxCLOSE_BOX )*/ );
    wxBoxSizer * sizer = new wxBoxSizer( wxVERTICAL );

    //wxImage::AddHandler( new wxTIFFHandler );
    wxBitmap logo_bitmap( miniAudicle_xpm );
    wxStaticBitmap * logo = new wxStaticBitmap( &about_dialog, wxID_ANY,
        logo_bitmap, wxDefaultPosition );
    sizer->Add( logo, 0, wxALL | wxALIGN_CENTER, 10 );

    wxString copystring;
    wxString about( MA_ABOUT, wxConvUTF8 ), version( MA_VERSION, wxConvUTF8 ),
        ck_version( CK_VERSION, wxConvUTF8 );
    copystring.Printf( about.c_str(), version.c_str(), ck_version.c_str() );
    copystring.Prepend( _T( "miniAudicle\n" ) );
    wxStaticText * copytext = new wxStaticText( &about_dialog, wxID_ANY, 
        copystring, wxDefaultPosition, wxDefaultSize, wxALIGN_CENTRE );
    sizer->Add( copytext, 1, wxLEFT | wxRIGHT | wxALIGN_CENTER, 10 );

    wxButton * button = new wxButton( &about_dialog, wxID_OK, _T( "OK" ) );
    sizer->Add( button, 0, wxALL | wxALIGN_CENTER, 10 );

    about_dialog.SetSizer( sizer );
}

mAParentFrame::~mAParentFrame()
{
    ma->free_document_id( docid );
}

void mAParentFrame::OnToggleVM( wxCommandEvent & event )
{
    if( vm_on )
    {
        ma->stop_vm();
        vm_on = false;
        
        wxGetApp().OnVMStop();
    }

    else
    {
        ma->start_vm();
        vm_on = true;
        
        wxGetApp().OnVMStart();
    }
}

void mAParentFrame::OnAdd( wxCommandEvent & event )
{
    if( !vm_on )
        return;
    
    mAChuckView * view = ( mAChuckView * ) m_docManager->GetCurrentView();
    
    if( view != NULL )
        view->Add();
}

void mAParentFrame::OnReplace( wxCommandEvent & event )
{
    if( !vm_on )
        return;
    
    mAChuckView * view = ( mAChuckView * ) m_docManager->GetCurrentView();
    
    if( view != NULL )
        view->Replace();
}

void mAParentFrame::OnRemove( wxCommandEvent & event )
{
    if( !vm_on )
        return;
    
    mAChuckView * view = ( mAChuckView * ) m_docManager->GetCurrentView();
    
    if( view != NULL )
        view->Remove();
}

void mAParentFrame::OnAddAllOpenDocuments( wxCommandEvent & event )
{
    if( !vm_on )
        return;
    
    wxList & doc_list = m_docManager->GetDocuments();
    
    size_t i = 0, len = doc_list.GetCount();
    for( ; i < len; i++ )
    {
        wxDocument * doc = ( wxDocument * ) doc_list[i];
        mAChuckView * view = ( mAChuckView * ) doc->GetFirstView();
        if( view != NULL )
            view->Add();
    }
}

void mAParentFrame::OnReplaceAllOpenDocuments( wxCommandEvent & event )
{
    if( !vm_on )
        return;
    
    wxList & doc_list = m_docManager->GetDocuments();
    
    size_t i = 0, len = doc_list.GetCount();
    for( ; i < len; i++ )
    {
        wxDocument * doc = ( wxDocument * ) doc_list[i];
        mAChuckView * view = ( mAChuckView * ) doc->GetFirstView();
        if( view != NULL )
            view->Replace();
    }
}

void mAParentFrame::OnRemoveAllOpenDocuments( wxCommandEvent & event )
{
    if( !vm_on )
        return;
    
    wxList & doc_list = m_docManager->GetDocuments();
    
    size_t i = 0, len = doc_list.GetCount();
    for( ; i < len; i++ )
    {
        wxDocument * doc = ( wxDocument * ) doc_list[i];
        mAChuckView * view = ( mAChuckView * ) doc->GetFirstView();
        if( view != NULL )
            view->Remove();
    }
}

void mAParentFrame::OnRemovelast( wxCommandEvent & event )
{
    if( !vm_on )
        return;

    string result;
    ma->removelast( docid, result );
}

void mAParentFrame::OnRemoveall( wxCommandEvent & event )
{
    if( !vm_on )
        return;

    string result;
    ma->removeall( docid, result );
}

//----------------------------------------------------------------------------
//  name: OnEditMenu
//  desc: For some reason, the wxTextCtrls arent responding to Edit menu
//  commands from the parent frame menubar.  So through this function the
//  parent frame receives them, and calls the appropriate methods on the 
//  active wxTextCtrl.
//----------------------------------------------------------------------------
void mAParentFrame::OnEditMenu( wxCommandEvent & event )
{
    mAChuckView * active_view = ( mAChuckView * ) m_docManager->GetCurrentView();
    if( active_view == NULL )
        return;

    wxStyledTextCtrl * active_text = active_view->window;

    if( active_text == NULL )
        return;

    wxKeyEvent key( wxEVT_CHAR );

    switch( event.GetId() )
    {
        case mAID_UNDO:
            active_text->Undo();
            break;
            
        case mAID_REDO:
            active_text->Redo();
            break;

        case mAID_CUT:
            active_text->Cut();
            break;

        case mAID_COPY:
            active_text->Copy();
            break;

        case mAID_PASTE:
            active_text->Paste();
            break;
/*
        case mAID_DELETE:
            key.m_altDown = key.m_shiftDown = key.m_controlDown = key.m_metaDown = false;
            key.m_keyCode = WXK_CLEAR;
            key.m_x = key.m_y = active_text->GetInsertionPoint();
            active_text->EmulateKeyPress( key );
            break;*/

        case mAID_SELECTALL:
            active_text->SelectAll();
            break;

    }
}

void mAParentFrame::OnCloseWindow( wxCloseEvent & event )
{
    wxConfigBase * config = wxConfigBase::Get();

    int x, y;

    GetSize( &x, &y );
    config->Write( _T( "/GUI/ParentFrame/width" ), x );
    config->Write( _T( "/GUI/ParentFrame/height" ), y );

    GetPosition( &x, &y );
    config->Write( _T( "/GUI/ParentFrame/x" ), x );
    config->Write( _T( "/GUI/ParentFrame/y" ), y );

    config->Write( _T( "/GUI/ParentFrame/maximize" ), IsMaximized() );
    
    wxDocMDIParentFrame::OnCloseWindow( event );

#if defined( __WINDOWS_DS__ )
    /* its ugly but its the only thing that seems to work */
    exit( 0 );
#endif
}

void mAParentFrame::OnAbout( wxCommandEvent & event )
{
    about_dialog.Show( true );
}

void mAParentFrame::OnMiniWeb( wxCommandEvent & event )
{
#if wxABI_VERSION > 206000 || !defined( __LINUX__ )
    wxLaunchDefaultBrowser( _T( "http://audicle.cs.princeton.edu/mini/" ) );
#endif
}

void mAParentFrame::OnChucKWeb( wxCommandEvent & event )
{
#if wxABI_VERSION > 206000 || !defined( __LINUX__ )
    wxLaunchDefaultBrowser( _T( "http://chuck.cs.princeton.edu/" ) );
#endif
}




