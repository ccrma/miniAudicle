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
// file: mAView.cpp
// desc: ChucK source view
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Summer 2006
//-----------------------------------------------------------------------------

#include "chuck_def.h"

#include "util_string.h"

#include "wx/wx.h"
#include "wx/config.h"
#include "wx/filename.h"

#include "mAView.h"
#include "mAParentFrame.h"
#include "mAEvents.h"

#ifdef __WINDOWS_DS__
#include "wxw/icons/add.xpm"
#include "wxw/icons/remove.xpm"
#include "wxw/icons/replace.xpm"
#endif

mAChuckWindow::mAChuckWindow( mAChuckView * v, wxMDIChildFrame * frame, 
                              wxWindowID id, const wxPoint & pos, 
                              const wxSize & size, long style)
    : wxStyledTextCtrl( frame, id, pos, size, style )
{
    view = v;
    open_brackets = close_brackets = 0;
    Connect( wxID_ANY, wxEVT_STC_CHARADDED, 
             (wxObjectEventFunction) (wxEventFunction) wxStaticCastEvent( wxStyledTextEventFunction, ( void (wxEvtHandler::*)( wxStyledTextEvent &) ) &mAChuckWindow::OnCharAdded ) );
    Connect( wxID_ANY, wxEVT_STC_MODIFIED, 
             (wxObjectEventFunction) (wxEventFunction) wxStaticCastEvent( wxStyledTextEventFunction, ( void (wxEvtHandler::*)( wxStyledTextEvent &) ) &mAChuckWindow::OnModify ) );
}

void mAChuckWindow::OnCharAdded( wxStyledTextEvent & event )
{
    int key = event.GetKey();
    if ( key == _T( '\n' ) )
    {
        int indentation = 0, line = LineFromPosition( GetSelectionStart() );

        if( line > 0)
            indentation = GetLineIndentation( line - 1 );

        while( open_brackets )
        {
            open_brackets--;
            indentation += GetTabWidth();
        }
        
        while( close_brackets )
        {
            close_brackets--;
            indentation -= GetTabWidth();
        }

        if( indentation < 0 )
            indentation = 0;

        SetLineIndentation( line, indentation );
        GotoPos( GetLineIndentPosition( line ) );
    }

    else if( key == _T( '{' ) )
        open_brackets++;

    else if( key == _T( '}' ) )
    {
        if( open_brackets )
            open_brackets--;
        else
        {
            int indentation = 0, line = LineFromPosition( GetSelectionStart() );
        
            if( GetLineIndentPosition( line ) == GetSelectionStart() - 1 )
                // this is the first non-indent character on this line
            {
                indentation = GetLineIndentation( line ) - GetTabWidth();
                
                if( indentation < 0 )
                    indentation = 0;

                SetLineIndentation ( line, indentation );
                GotoPos( GetLineIndentPosition( line ) + 1 );
            }
            else
                close_brackets++;
        }
    }
}

void mAChuckWindow::OnModify( wxStyledTextEvent & event )
{
    view->SetModified( true );
}

IMPLEMENT_DYNAMIC_CLASS( mAChuckView, wxView )

bool mAChuckView::OnCreate( wxDocument * doc, long WXUNUSED( flags ) )
{
    frame = wxGetApp().CreateChildFrame( doc, this );
    
//  wxConfigBase * config = wxConfigBase::Get();

    int width, height;
    frame->GetClientSize( &width, &height );
    
    wxBoxSizer * top_level_sizer = new wxBoxSizer( wxVERTICAL );

    window = new mAChuckWindow( this, frame, wxID_ANY, wxPoint(0, 0), 
        wxSize( width, height ), wxSTC_STYLE_LINENUMBER );
    
    // set width to 80 columns
    int frame_width = window->TextWidth( wxSTC_STYLE_DEFAULT, _T( "                                                                     ") );
    int frame_height = window->TextHeight( 1 ) * 32;
    int frame_x, frame_y;
    frame->GetPosition( &frame_x, &frame_y );

    wxDocMDIParentFrame * parent_frame = ( wxDocMDIParentFrame * ) frame->GetParent();
    int client_width, client_height;
    parent_frame->GetClientSize( &client_width, &client_height );
    
    if( frame_width + frame_x > ( .8 * client_width ) )
        frame_width = ( int ) ( .8 * client_width - frame_x );
    if( frame_height + frame_y > ( .8 * client_height ) )
        frame_height = ( int ) ( .8 * client_height - frame_y );
    frame->SetSize( frame_width, frame_height );
    
    window->StyleClearAll();

    window->SetLexer( wxSTC_LEX_CPP );
    window->SetKeyWords( 0, _T( "int float time dur void same if else while do " ) 
                            _T( "until for break continue return switch repeat " )
                            _T( "class extends public static pure this " )
                            _T( "super interface implements protected " )
                            _T( "private function fun spork const new now " )
                            _T( "true false maybe null NULL me pi samp ms " )
                            _T( "second minute hour day week dac adc blackhole " ) );
    // load initial syntax coloring preferences
    this->SyntaxColoringPreferencesChanged();

    // load initial editing preferences
    this->EditingPreferencesChanged();

    frame->CreateStatusBar();
    frame->SetStatusText( _T( "" ) );

    //wxToolBar * toolbar = frame->CreateToolBar( wxTB_HORIZONTAL | wxTB_TEXT | wxTB_FLAT );
#ifdef __WINDOWS_DS__
    /* In Windows, have a toolbar for each document window. 
       Linux doesnt support this.  */
    otf_toolbar = new wxToolBar( frame, wxID_ANY, wxDefaultPosition, 
        wxDefaultSize, wxTB_HORIZONTAL | wxTB_TEXT | wxTB_FLAT );

    wxSize bitmap_size( 32, 32 );
    otf_toolbar->SetToolBitmapSize( bitmap_size );

    wxBitmap add_bitmap( add_xpm );
    otf_toolbar->AddTool( mAID_ADD, _T( "Add Shred" ), add_bitmap );

    otf_toolbar->AddSeparator();

    wxBitmap replace_bitmap( replace_xpm );
    otf_toolbar->AddTool( mAID_REPLACE, _T( "Replace Shred" ), replace_bitmap );

    otf_toolbar->AddSeparator();

    wxBitmap remove_bitmap( remove_xpm );
    otf_toolbar->AddTool( mAID_REMOVE, _T( "Remove Shred" ), remove_bitmap );

    /*
    toolbar->AddSeparator();

    wxBitmap removelast_bitmap( _T( "removelast" ) );
    toolbar->AddTool( mAID_REMOVELAST, _T( "Remove Last" ), 
        removelast_bitmap );

    toolbar->AddSeparator();
    wxBitmap removeall_bitmap( _T( "removeall" ) );
    toolbar->AddTool( mAID_REMOVEALL, _T( "Remove All" ), 
        removeall_bitmap );
    //*/

    otf_toolbar->EnableTool( mAID_ADD, ma->is_on() );
    otf_toolbar->EnableTool( mAID_REMOVE, ma->is_on() );
    otf_toolbar->EnableTool( mAID_REPLACE, ma->is_on() );

    otf_toolbar->Realize();

    top_level_sizer->Add( otf_toolbar, 0, wxEXPAND );
#endif

    wxToolBar * arguments_toolbar = new wxToolBar( frame, wxID_ANY, wxDefaultPosition, 
        wxDefaultSize, wxTB_HORIZONTAL | wxTB_TEXT | wxTB_FLAT | wxTB_NOICONS );
    
    //arguments_toolbar->AddTool( mAID_VIEW_ARGUMENTS_TOGGLE, _T( "arguments" ),
    //    wxNullBitmap, _T( "" ), wxITEM_CHECK );
    //arguments_toolbar->EnableTool( mAID_VIEW_ARGUMENTS_TOGGLE, false );
    arguments_toolbar->AddControl( new wxStaticText( arguments_toolbar, 
        wxID_ANY, _T( " arguments " ) ) );

    arguments_text = new wxTextCtrl( arguments_toolbar, 
        mAID_VIEW_ARGUMENTS_TEXT, _T( "" ), wxDefaultPosition, 
        wxSize( 190, -1 ) );
    arguments_toolbar->AddControl( arguments_text );

    arguments_toolbar->AddTool( 0, _T( " " ), wxNullBitmap );
    arguments_toolbar->EnableTool( 0, false );

    arguments_toolbar->Realize();

    top_level_sizer->Add( arguments_toolbar, 0, wxTOP | wxBOTTOM | wxEXPAND, 2 );

    top_level_sizer->Add( window, 1, wxEXPAND );

    frame->SetSizer( top_level_sizer );

    docid = ma->allocate_document_id();

    frame->RegisterWithWindowMenu();
    
    is_modified = false;
    
    frame->Show( true );
    Activate( true );
    window->SetFocus();
    
    return true;
}

void mAChuckView::SetMiniAudicle( miniAudicle * ma )
{
    this->ma = ma;
}

// Handled by wxTextWindow
void mAChuckView::OnDraw( wxDC * WXUNUSED( dc ) )
{
}

void mAChuckView::OnUpdate( wxView * WXUNUSED( sender ), 
                            wxObject * WXUNUSED( hint ) )
{
}

void mAChuckView::OnChangeFilename()
{
    wxView::OnChangeFilename();
    wxString title = GetDocument()->GetTitle();
    if( title == _T( "" ) )
        title = wxFileName( GetDocument()->GetFilename() ).GetFullName();
    if( title == _T( "" ) )
        title = _T( "(no name)" );
    
    if( is_modified )
        title = title.Prepend( _T( "*" ) );
    
    frame->SetTitle( title );
    frame->ReregisterWithWindowMenu();
}

void mAChuckView::SetModified( bool modified )
{
    if( modified != is_modified )
    {
        is_modified = modified;
        
        OnChangeFilename();
    }
}

bool mAChuckView::OnClose( bool deleteWindow )
{
    ma->free_document_id( docid );
    if( !GetDocument()->Close() )
        return false;
    
    Activate( false );

    frame->DeregisterWithWindowMenu();
    
    if( deleteWindow )
    {
        frame->Destroy();
    }

    wxGetApp().RemoveView( this );

    return true;
}

void mAChuckView::Add()
{
    std::string code = std::string( window->GetText().ToAscii() ),
        name = std::string( frame->GetTitle().ToAscii() ),
        result;
    t_CKUINT shred_id;
    
    std::vector< string > argv;
    std::string filename;
    
    std::string args_string = std::string( "filename:" ) + 
        std::string( arguments_text->GetValue().ToAscii() );

    if( !extract_args( args_string, filename, argv ) )
        argv.clear();

    t_CKUINT result_code = ma->run_code( code, name, argv, docid, shred_id, result );

    if( result_code == OTF_VM_TIMEOUT )
    {
        wxGetApp().SetLockdown( TRUE );
    }
    
    wxString status( result.c_str(), wxConvUTF8 );
    
    frame->SetStatusText( status );
}


void mAChuckView::Remove()
{
    std::string result;
    t_CKUINT shred_id;

    ma->remove_code( docid, shred_id, result );
    
    wxString status( result.c_str(), wxConvUTF8 );
    
    frame->SetStatusText( status );
}

void mAChuckView::Replace()
{
    std::string code = std::string( window->GetText().ToAscii() ),
        name = std::string( frame->GetTitle().ToAscii() ),
        result;
    t_CKUINT shred_id;
    
    std::vector< string > argv;
    std::string filename;
    
    std::string args_string = std::string( "filename:" ) + 
        std::string( arguments_text->GetValue().ToAscii() );

    if( !extract_args( args_string, filename, argv ) )
        argv.clear();

    ma->replace_code( code, name, argv, docid, shred_id, result );

    wxString status( result.c_str(), wxConvUTF8 );
    
    frame->SetStatusText( status );
}

void mAChuckView::OnVMStart()
{
#ifdef __WINDOWS_DS__
    otf_toolbar->EnableTool( mAID_ADD, true );
    otf_toolbar->EnableTool( mAID_REMOVE, true );
    otf_toolbar->EnableTool( mAID_REPLACE, true );
#endif
}

void mAChuckView::OnVMStop()
{
#ifdef __WINDOWS_DS__
    otf_toolbar->EnableTool( mAID_ADD, false );
    otf_toolbar->EnableTool( mAID_REMOVE, false );
    otf_toolbar->EnableTool( mAID_REPLACE, false );
#endif
}

void mAChuckView::EditingPreferencesChanged()
{
    wxConfigBase * config = wxConfigBase::Get();

    long l;
    long font_size;
    bool b;
    wxString str;
    
#ifdef __LINUX__
    config->Read( mAPreferencesFontSize, &font_size, 10 );
#else
    config->Read( mAPreferencesFontSize, &font_size, 11 );
#endif
    
    config->Read( mAPreferencesFontName, &str, 
                  wxFont( 10, wxFONTFAMILY_MODERN, wxNORMAL, 
                          wxFONTWEIGHT_NORMAL ).GetFaceName() );
    
    wxFont font( font_size, wxFONTFAMILY_MODERN, wxNORMAL, wxFONTWEIGHT_NORMAL,
                 false, str );
    window->StyleSetFont( wxSTC_STYLE_DEFAULT, font );
    window->StyleSetFont( wxSTC_C_DEFAULT, font );
    window->StyleSetFont( wxSTC_C_IDENTIFIER, font );
    window->StyleSetFont( wxSTC_C_OPERATOR, font );
    window->StyleSetFont( wxSTC_C_WORD, font );
    window->StyleSetFont( wxSTC_C_STRING, font );
    window->StyleSetFont( wxSTC_C_COMMENT, font );
    window->StyleSetFont( wxSTC_C_COMMENTLINE, font );
    window->StyleSetFont( wxSTC_C_NUMBER, font );
    
    config->Read( mAPreferencesUseTabs, &b, false );
    window->SetUseTabs( b );
    
    config->Read( mAPreferencesTabSize, &l, 4 );
    window->SetTabWidth( l );
    
    config->Read( mAPreferencesShowLineNumbers, &b, true );
    
    if( b )
    {
        window->SetMarginType( 1, wxSTC_MARGIN_NUMBER );
        wxFont ln_font( 9, wxFONTFAMILY_MODERN, wxNORMAL, wxFONTWEIGHT_NORMAL );
        window->StyleSetFont( wxSTC_STYLE_LINENUMBER, ln_font );
        window->StyleSetBackground( wxSTC_STYLE_LINENUMBER, wxColour( 212, 208, 200 ) );
        window->StyleSetForeground( wxSTC_STYLE_LINENUMBER, *wxBLACK );
        window->SetMarginWidth( 1, window->TextWidth( wxSTC_STYLE_LINENUMBER, _T( "9999") ) );
        window->SetMarginLeft( 5 );
    }
    
    else
    {
        window->SetMarginWidth( 1, 0 );
    }
    
}

void mAChuckView::SyntaxColoringPreferencesChanged()
{
    wxConfigBase * config = wxConfigBase::Get();

    long l;
    
    config->Read( mAPreferencesSyntaxColoringNormalText, &l, 0x000000 );
    window->StyleSetForeground( wxSTC_C_DEFAULT, wxColour( ( l >> 16 ) & 0xff,
                                                           ( l >> 8 ) & 0xff,
                                                           ( l ) & 0xff ) );
    window->StyleSetForeground( wxSTC_C_IDENTIFIER, wxColour( ( l >> 16 ) & 0xff,
                                                              ( l >> 8 ) & 0xff,
                                                              ( l ) & 0xff ) );
    window->StyleSetForeground( wxSTC_C_OPERATOR, wxColour( ( l >> 16 ) & 0xff,
                                                            ( l >> 8 ) & 0xff,
                                                            ( l ) & 0xff ) );
    
    config->Read( mAPreferencesSyntaxColoringKeywords, &l, 0x0000ff );
    window->StyleSetForeground( wxSTC_C_WORD, wxColour( ( l >> 16 ) & 0xff,
                                                           ( l >> 8 ) & 0xff,
                                                           ( l ) & 0xff ) );
    
    
    config->Read( mAPreferencesSyntaxColoringComments, &l, 0x609010 );
    window->StyleSetForeground( wxSTC_C_COMMENT, wxColour( ( l >> 16 ) & 0xff,
                                                           ( l >> 8 ) & 0xff,
                                                           ( l ) & 0xff ) );
    window->StyleSetForeground( wxSTC_C_COMMENTLINE, wxColour( ( l >> 16 ) & 0xff,
                                                           ( l >> 8 ) & 0xff,
                                                           ( l ) & 0xff ) );
    
    
    config->Read( mAPreferencesSyntaxColoringStrings, &l, 0x404040 );
    window->StyleSetForeground( wxSTC_C_STRING, wxColour( ( l >> 16 ) & 0xff,
                                                           ( l >> 8 ) & 0xff,
                                                           ( l ) & 0xff ) );
    
    
    config->Read( mAPreferencesSyntaxColoringNumbers, &l, 0xd48010 );
    window->StyleSetForeground( wxSTC_C_NUMBER, wxColour( ( l >> 16 ) & 0xff,
                                                           ( l >> 8 ) & 0xff,
                                                           ( l ) & 0xff ) );
    
}

mADocMDIChildFrame::mADocMDIChildFrame( wxDocument * doc, wxView * view, 
    wxMDIParentFrame * parent, wxWindowID id, const wxString & title, 
    const wxPoint & pos, const wxSize & size, long style, const wxString & name )
    : wxDocMDIChildFrame( doc, view, parent, id, title, pos, size, style, name )
{
    m_menuid = -1;
}

void mADocMDIChildFrame::RegisterWithWindowMenu()
{
    if( m_menuid == -1 )
        m_menuid = wxGetApp().AddWindowMenuItem( ( mAFrameType * ) this );
}

void mADocMDIChildFrame::DeregisterWithWindowMenu()
{
    if( m_menuid != -1 )
        wxGetApp().RemoveWindowMenuItem( m_menuid );
    m_menuid = -1;
}

void mADocMDIChildFrame::ReregisterWithWindowMenu()
{
    if( m_menuid == -1 )
        RegisterWithWindowMenu();
    wxGetApp().ChangeWindowMenuItem( m_menuid );
}



