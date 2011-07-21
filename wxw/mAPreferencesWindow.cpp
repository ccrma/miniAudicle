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
// file: mAPreferencesWindow.cpp
// desc: preferences window controller
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Fall 2006
//-----------------------------------------------------------------------------

#include "chuck_def.h"
#include "digiio_rtaudio.h"

#include "miniAudicle.h"

#include "wx/wx.h"
#include "wx/config.h"
#include "wx/colordlg.h"
#include "wx/fontdlg.h"

#include "mAPreferencesWindow.h"
#include "mAEvents.h"
#include "mAParentFrame.h"


#ifdef __WINDOWS_DS__
const wxString mAPreferencesDefaultChuGinPaths = _T( "dC:\\WINDOWS\\system32\\ChucK" );
const wxChar mAPreferencesPathSeparator = ';';
#else
const wxString mAPreferencesDefaultChuGinPaths = _T( "d/usr/lib/chuck" );
const wxChar mAPreferencesPathSeparator = ':';
#endif


const wxString mAPreferencesParentFrameWidth = _T( "/GUI/ParentFrame/width" );
const wxString mAPreferencesParentFrameHeight = _T( "/GUI/ParentFrame/height" );
const wxString mAPreferencesParentFrameX = _T( "/GUI/ParentFrame/x" );
const wxString mAPreferencesParentFrameY = _T( "/GUI/ParentFrame/y" );
const wxString mAPreferencesParentFrameMaximize = _T( "/GUI/ParentFrame/maximize" );
const wxString mAPreferencesVMMonitorWidth = _T( "/GUI/VMMonitor/width" );
const wxString mAPreferencesVMMonitorHeight = _T( "/GUI/VMMonitor/height" );
const wxString mAPreferencesVMMonitorX = _T( "/GUI/VMMonitor/x" );
const wxString mAPreferencesVMMonitorY = _T( "/GUI/VMMonitor/y" );
const wxString mAPreferencesVMMonitorMaximize = _T( "/GUI/VMMonitor/maximize" );
const wxString mAPreferencesConsoleMonitorWidth = _T( "/GUI/ConsoleMonitor/width" );
const wxString mAPreferencesConsoleMonitorHeight = _T( "/GUI/ConsoleMonitor/height" );
const wxString mAPreferencesConsoleMonitorX = _T( "/GUI/ConsoleMonitor/x" );
const wxString mAPreferencesConsoleMonitorY = _T( "/GUI/ConsoleMonitor/y" );
const wxString mAPreferencesConsoleMonitorMaximize = _T( "/GUI/ConsoleMonitor/maximize" );

const wxString mAPreferencesFontName = _T( "/GUI/Editing/FontName" );
const wxString mAPreferencesFontSize = _T( "/GUI/Editing/FontSize" );

const wxString mAPreferencesSyntaxColoringEnabled = _T( "/GUI/Editing/SyntaxColoringEnabled" );
const wxString mAPreferencesSyntaxColoringNormalText = _T( "/GUI/Editing/SyntaxColoring/NormalText" );
const wxString mAPreferencesSyntaxColoringKeywords = _T( "/GUI/Editing/SyntaxColoring/Keywords" );
const wxString mAPreferencesSyntaxColoringComments = _T( "/GUI/Editing/SyntaxColoring/Comments" );
const wxString mAPreferencesSyntaxColoringStrings = _T( "/GUI/Editing/SyntaxColoring/Strings" );
const wxString mAPreferencesSyntaxColoringNumbers = _T( "/GUI/Editing/SyntaxColoring/Numbers" );
const wxString mAPreferencesSyntaxColoringBackground = _T( "/GUI/Editing/SyntaxColoring/Background" );

const wxString mAPreferencesUseTabs = _T( "/GUI/Editing/UsesTabs" );
const wxString mAPreferencesTabSize = _T( "/GUI/Editing/TabSize" );
const wxString mAPreferencesShowLineNumbers = _T( "/GUI/Editing/ShowLineNumbers" );

const wxString mAPreferencesCurrentDirectory = _T( "/Miscellaneous/CurrentDirectory" );

const wxString mAPreferencesEnableChuGins = _T( "/ChuGins/Enable" );
const wxString mAPreferencesChuGinPaths = _T( "/ChuGins/Paths" );

const wxString mAPreferencesAudioOutput = _T( "/VM/DAC" );
const wxString mAPreferencesAudioInput = _T( "/VM/ADC" );
const wxString mAPreferencesOutputChannels = _T( "/VM/OutputChannels" );
const wxString mAPreferencesInputChannels = _T( "/VM/InputChannels" );
const wxString mAPreferencesSampleRate = _T( "/VM/SampleRate" );
const wxString mAPreferencesBufferSize = _T( "/VM/SampleBufferSize" );
const wxString mAPreferencesVMStallTimeout = _T( "/VM/StallTimeout" );

const wxString mAPreferencesEnableNetwork = _T( "/VM/EnableNetworkOTFCommands" );
const wxString mAPreferencesEnableAudio = _T( "/VM/EnableAudio" );


struct __sc_token
{
    __sc_token( const wxString * _key, const wxString & _name, long _color )
        : key( _key ), name( _name ), color( _color )
    { }

    const wxString * key;
    const wxString name;
    const long color;
};

__sc_token sc_tokens[] = 
{
    __sc_token( &mAPreferencesSyntaxColoringNormalText, _T( "Normal Text" ), 0x000000 ),
    __sc_token( &mAPreferencesSyntaxColoringKeywords,   _T( "Keywords" ),    0x0000ff ),
    __sc_token( &mAPreferencesSyntaxColoringComments,   _T( "Comments" ),    0x609010 ),
    __sc_token( &mAPreferencesSyntaxColoringStrings,    _T( "Strings" ),     0x404040 ),
    __sc_token( &mAPreferencesSyntaxColoringNumbers,    _T( "Numbers" ),     0xd48010 ),
    __sc_token( &mAPreferencesSyntaxColoringBackground, _T( "Background" ),  0xffffff ),
    __sc_token( NULL, _T( "" ), 0 )
};


void DeserializeChuGinPaths(wxString pathstr, std::vector<ChuGinPath> & pathv)
{
    while(pathstr != wxEmptyString && pathstr.Length() > 0)
    {
        wxString path = pathstr.BeforeFirst(mAPreferencesPathSeparator);
        if(path != wxEmptyString && path.Length() > 0)
        {
            ChuGinPath::Type type;
            if(path[0] == 'd')
                type = ChuGinPath::DIRECTORY_TYPE;
            else if(path[0] == 'c')
                type = ChuGinPath::CHUGIN_TYPE;
            else
                // uhh
                type = ChuGinPath::CHUGIN_TYPE;

            pathv.push_back(ChuGinPath(type, path.SubString(1, path.Length()-1)));
        }
        pathstr = pathstr.AfterFirst(mAPreferencesPathSeparator);
    }
}

void SerializeChuGinPaths(wxString & pathstr, std::vector<ChuGinPath> & pathv)
{
    for(std::vector<ChuGinPath>::iterator i = pathv.begin(); i != pathv.end(); i++)
    {
        if(i != pathv.begin())
            pathstr.Append(mAPreferencesPathSeparator);
        if((*i).type == ChuGinPath::DIRECTORY_TYPE)
            pathstr.Append('d');
        else
            pathstr.Append('c');
        pathstr.Append((*i).path);
    }
}



mAPreferencesWindow::mAPreferencesWindow( miniAudicle * ma, 
    mAWindowParent * parent, wxWindowID id, const wxString & title, 
    const wxPoint & pos, const wxSize & size, long style )
    : mAWindowSuper( parent, id, title, pos, size, style ),
    font( NULL )
{
    SetSize( 350, 350 );
    Center();
    Hide();

#ifdef __WINDOWS_DS__
    /* the default background is white, which looks bad */
    SetOwnBackgroundColour( wxSystemSettings::GetColour( wxSYS_COLOUR_BTNFACE ) );
#endif
    
    this->ma = ma;
    
    int x, y, w, h;
    GetPosition( &x, &y );
    GetSize( &w, &h );

    // initialize top level sizer
    wxBoxSizer * top = new wxBoxSizer( wxVERTICAL );

    // create the notebook (tabbed-view) control
    notebook = new wxNotebook( this, wxID_ANY );
    top->Add( notebook, 2, wxALL | wxEXPAND, 10 );

    /*** create/populate the audio page of the notebook ***/
    audio_page = new wxPanel( notebook, wxID_ANY );

    notebook->AddPage( audio_page, _T( "Audio" ) );
    
    wxBoxSizer * audio_page_top = new wxBoxSizer( wxVERTICAL );
    wxSizer * audio_page_sizers[4];

    audio_page_sizers[0] = new wxBoxSizer( wxHORIZONTAL );
    
    // enable real-time audio
    enable_audio = new wxCheckBox( audio_page, wxID_ANY, 
                                   _T( "Enable audio" ) );
    enable_audio->SetValue( true );
    audio_page_sizers[0]->Add( enable_audio );

    audio_page_sizers[0]->Add( 10, 0, 1 );

    // enable network thread
    enable_network = new wxCheckBox( audio_page, wxID_ANY, 
                                     _T( "Accept network VM commands" ) );
    audio_page_sizers[0]->Add( enable_network );

    audio_page_top->Add( audio_page_sizers[0], 0, 
                         wxTOP | wxLEFT | wxRIGHT | wxBOTTOM | wxEXPAND, 10 );

    // 
    audio_page_sizers[1] = new wxFlexGridSizer( 2, 2, 5, 10 );
    ( ( wxFlexGridSizer * ) audio_page_sizers[1] )->AddGrowableCol( 1 );
    
    // audio output selector
    audio_page_sizers[1]->Add( new wxStaticText( audio_page, wxID_ANY, 
                                                 _T( "Audio Output:" ) ),
                               0, wxALIGN_CENTER_VERTICAL );
    audio_output = new wxChoice( audio_page, mAID_PREFS_AUDIO_OUTPUT );
    audio_output->Append( _T( "Default" ) );
    audio_output->Append( _T( "(nothing)" ) );
    audio_output->SetSelection( 0 );
    audio_page_sizers[1]->Add( audio_output, 0, wxEXPAND | wxALIGN_CENTER_VERTICAL );

    Connect( mAID_PREFS_AUDIO_OUTPUT, wxEVT_COMMAND_CHOICE_SELECTED,
        wxCommandEventHandler( mAPreferencesWindow::OnSelectedAudioOutputChanged ) );

    // audio input selector
    audio_page_sizers[1]->Add( new wxStaticText( audio_page, wxID_ANY, 
                                                 _T( "Audio Input:" ) ),
                               0, wxALIGN_CENTER_VERTICAL );
    audio_input = new wxChoice( audio_page, wxID_ANY ); // TODO: needs a real id
    audio_input->Append( _T( "Default" ) );
    audio_input->Append( _T( "(nothing)" ) );
    audio_input->SetSelection( 0 );
    audio_page_sizers[1]->Add( audio_input, 0, wxEXPAND | wxALIGN_CENTER_VERTICAL );

    Connect( mAID_PREFS_AUDIO_INPUT, wxEVT_COMMAND_CHOICE_SELECTED,
        wxCommandEventHandler( mAPreferencesWindow::OnSelectedAudioInputChanged ) );

    //
    audio_page_top->Add( audio_page_sizers[1], 0, 
                         wxLEFT | wxRIGHT | wxBOTTOM | wxEXPAND, 10 );

    //
    audio_page_sizers[2] = new wxBoxSizer( wxHORIZONTAL );

    // output channels
    audio_page_sizers[2]->Add( new wxStaticText( audio_page, wxID_ANY, 
                                                 _T( "Output Channels:" ) ),
                               0, wxALIGN_CENTER_VERTICAL | wxRIGHT, 5 );
    output_channels = new wxChoice( audio_page, wxID_ANY );
    output_channels->Append( _T( "1" ) );
    output_channels->Append( _T( "2" ) );
    output_channels->Append( _T( "32" ) );
    output_channels->SetSelection( 1 );
    audio_page_sizers[2]->Add( output_channels, 0, wxALIGN_CENTER_VERTICAL );

    // spacer
    audio_page_sizers[2]->AddStretchSpacer();

    // input channels
    audio_page_sizers[2]->Add( new wxStaticText( audio_page, wxID_ANY, 
                                                 _T( "Input Channels:" ) ),
                               0, wxALIGN_CENTER_VERTICAL | wxRIGHT, 5 );
    input_channels = new wxChoice( audio_page, wxID_ANY );
    input_channels->Append( _T( "1" ) );
    input_channels->Append( _T( "2" ) );
    input_channels->Append( _T( "32" ) );
    input_channels->SetSelection( 1 );
    audio_page_sizers[2]->Add( input_channels, 0, wxALIGN_CENTER_VERTICAL );

    //
    audio_page_top->Add( audio_page_sizers[2], 0,
                         wxLEFT | wxRIGHT | wxBOTTOM | wxEXPAND, 10 );

    //
    audio_page_sizers[3] = new wxBoxSizer( wxHORIZONTAL );

    // sample rate
    audio_page_sizers[3]->Add( new wxStaticText( audio_page, wxID_ANY,
                                                 _T( "Sample Rate:" ) ),
                               0, wxALIGN_CENTER_VERTICAL | wxRIGHT, 5 );
    sample_rate = new wxChoice( audio_page, wxID_ANY );
    sample_rate->Append( _T( "11025" ) );
    sample_rate->Append( _T( "22050" ) );
    sample_rate->Append( _T( "44100" ) );
    sample_rate->Append( _T( "192000" ) );
    sample_rate->SetSelection( 3 );
    audio_page_sizers[3]->Add( sample_rate, 7, wxALIGN_CENTER_VERTICAL );

    // spacer
    audio_page_sizers[3]->AddStretchSpacer( 1 );

    // buffer size
    audio_page_sizers[3]->Add( new wxStaticText( audio_page, wxID_ANY,
                                                 _T( "Buffer Size:" ) ),
                               0, wxALIGN_CENTER_VERTICAL | wxRIGHT, 5 );
    buffer_size = new wxChoice( audio_page, wxID_ANY );
    buffer_size->Append( _T( "16" ), ( void * ) 16 );
    buffer_size->Append( _T( "32" ), ( void * ) 32 );
    buffer_size->Append( _T( "64" ), ( void * ) 64 );
    buffer_size->Append( _T( "128" ), ( void * ) 128 );
    buffer_size->Append( _T( "256" ), ( void * ) 256 );
    buffer_size->Append( _T( "512" ), ( void * ) 512 );
    buffer_size->Append( _T( "1024" ), ( void * ) 1024 );
    buffer_size->Append( _T( "2048" ), ( void * ) 2048 );
    buffer_size->SetSelection( 4 );
    audio_page_sizers[3]->Add( buffer_size, 6, wxALIGN_CENTER_VERTICAL );

    // add 
    audio_page_top->Add( audio_page_sizers[3], 0,
                         wxLEFT | wxRIGHT | wxBOTTOM | wxEXPAND, 10 );
    
    audio_page_top->AddSpacer( 10 );
    
    // add audio probe 
    audio_page_top->Add( new wxButton( audio_page, 
                                       mAID_PREFS_PROBE_AUDIO, 
                                       _T( "Probe Audio Interfaces" ) ),
                         0, wxALIGN_CENTER | wxLEFT | wxRIGHT | wxBOTTOM, 10 );
    Connect( mAID_PREFS_PROBE_AUDIO, wxEVT_COMMAND_BUTTON_CLICKED, 
        wxCommandEventHandler( mAPreferencesWindow::OnProbeAudioDevices ) );
    
    audio_page_top->AddSpacer( 10 );
    
#ifdef __WINDOWS_DS__
    wxStaticText * restart = new wxStaticText( audio_page, wxID_ANY,
                                               _T( "Changes will not take effect until miniAudicle is restarted." ) );
#else
    wxStaticText * restart = new wxStaticText( audio_page, wxID_ANY,
                                               _T( "Changes will not take effect until virtual machine is restarted." ) );
#endif
    restart->GetFont().SetPointSize( 10 );
    audio_page_top->Add( restart, 0, 
                         wxALIGN_CENTER | wxLEFT | wxRIGHT | wxBOTTOM, 10 );

    audio_page_top->AddSpacer( 10 );
    
    audio_page_top->AddStretchSpacer();
                                           
    //
    audio_page->SetSizer( audio_page_top );
    audio_page_top->Fit( audio_page );
    
    /*** create/populate the editing page of the notebook ***/
    editing_page = new wxPanel( notebook );
    notebook->AddPage( editing_page, _T( "Editing" ) );

    wxBoxSizer * editing_page_top = new wxBoxSizer( wxVERTICAL );
    wxSizer * editing_page_sizers[3];

    // add font selection
    editing_page_sizers[0] = new wxBoxSizer( wxHORIZONTAL );

    editing_page_sizers[0]->Add( new wxStaticText( editing_page, wxID_ANY,
                                                   _T( "Editing Font:" ) ),
                                 0, wxALIGN_CENTER_VERTICAL );
    editing_page_sizers[0]->AddStretchSpacer();
    editing_page_sizers[0]->Add( new wxButton( editing_page, mAID_PREFS_CHOOSE_FONT,
                                               _T( "Set Editing Font..." ) ) );
    Connect( mAID_PREFS_CHOOSE_FONT, wxEVT_COMMAND_BUTTON_CLICKED,
        wxCommandEventHandler( mAPreferencesWindow::OnChooseFont ) );

    //
    editing_page_top->Add( editing_page_sizers[0], 0,
                           wxTOP | wxLEFT | wxRIGHT | wxBOTTOM | wxEXPAND, 10 );

    // 
    font_display = new wxTextCtrl( editing_page, wxID_ANY, _T( "Courier - 10pt" ),
                                   wxDefaultPosition, wxDefaultSize, wxTE_READONLY );
    editing_page_top->Add( font_display, 0, wxLEFT | wxRIGHT | wxBOTTOM | wxEXPAND, 10 );
    
    // syntax coloring
    enable_coloring = new wxCheckBox( editing_page, wxID_ANY, _T( "Enable syntax coloring" ) );
    enable_coloring->SetValue( true );

    editing_page_top->Add( enable_coloring, 0, wxLEFT | wxRIGHT | wxBOTTOM | wxEXPAND, 10 );
    
    //
    editing_page_sizers[1] = new wxBoxSizer( wxHORIZONTAL );
    
    editing_page_sizers[1]->AddSpacer( 10 );

    //
    color_items = new wxChoice( editing_page, mAID_PREFS_SYNTAX_COLORING_ITEM_CHANGED );
    for( int i = 0; sc_tokens[i].key != NULL; i++ )
        color_items->Append( sc_tokens[i].name );
    color_items->SetSelection( 0 );
    editing_page_sizers[1]->Add( color_items, 1 );
    Connect( mAID_PREFS_SYNTAX_COLORING_ITEM_CHANGED, wxEVT_COMMAND_CHOICE_SELECTED,
        wxCommandEventHandler( mAPreferencesWindow::OnSelectSyntaxColoringItem ) );

    //
    editing_page_sizers[1]->AddSpacer( 10 );

    //
    color_button = new wxButton( editing_page, mAID_PREFS_CHOOSE_SYNTAX_COLOR,
                                 _T( " " ), wxDefaultPosition,
                                 wxSize( -1, color_items->GetSize().GetHeight() ) );
    color_button->SetBackgroundColour( *wxBLACK );
    editing_page_sizers[1]->Add( color_button, 0, wxEXPAND );
    Connect( mAID_PREFS_CHOOSE_SYNTAX_COLOR, wxEVT_COMMAND_BUTTON_CLICKED,
             wxCommandEventHandler( mAPreferencesWindow::OnChooseSyntaxColor ) );
    
    editing_page_sizers[1]->AddStretchSpacer();
    
    //
    editing_page_top->Add( editing_page_sizers[1], 0, 
                           wxLEFT | wxRIGHT | wxBOTTOM | wxEXPAND, 10 );
    editing_page_top->AddSpacer( 5 );

    // tabs
    tab_key_tabs = new wxCheckBox( editing_page, wxID_ANY,
                                   _T( "Tab key inserts tabs, not spaces" ) );
    tab_key_tabs->SetValue( true );

    editing_page_top->Add( tab_key_tabs, 0, 
                           wxLEFT | wxRIGHT | wxBOTTOM | wxEXPAND, 10 );

    // 
    editing_page_sizers[2] = new wxBoxSizer( wxHORIZONTAL );
    editing_page_sizers[2]->AddSpacer( 10 );
    editing_page_sizers[2]->Add( new wxStaticText( editing_page, wxID_ANY, 
                                                   _T( "Tab width:" ) ),
                                 0, wxALIGN_CENTER_VERTICAL | wxRIGHT, 5 );

    //
    tab_size = new wxTextCtrl( editing_page, wxID_ANY, _T( "4" ) );
    tab_size->SetMaxLength( 2 );
    wxSize _size = tab_size->ConvertDialogToPixels( wxSize( 16, 10 ) );
    tab_size->SetSize( _size.GetWidth(), -1 );
    tab_size->SetMaxSize( tab_size->GetSize() );
    editing_page_sizers[2]->Add( tab_size, 0, wxSHAPED );

    // 
    editing_page_top->Add( editing_page_sizers[2], 0, 
                           wxLEFT | wxRIGHT | wxBOTTOM | wxEXPAND, 10 );
    editing_page_top->AddSpacer( 5 );

    // line numbers
    line_numbers = new wxCheckBox( editing_page, wxID_ANY, 
                                   _T( "Display line numbers" ) );
    line_numbers->SetValue( true );
    
    editing_page_top->Add( line_numbers, 0, 
                           wxLEFT | wxRIGHT | wxBOTTOM | wxEXPAND, 10 );

    //
    editing_page_top->AddStretchSpacer();
    editing_page->SetSizer( editing_page_top );
    editing_page->Fit();


    /*** create/populate the chugin page of the notebook ***/

    chugin_page = new wxPanel( notebook );
    notebook->AddPage( chugin_page, _T( "ChuGins" ) );

    wxSizer * chugin_page_sizer = new wxBoxSizer(wxVERTICAL);
    
    enable_chugins = new wxCheckBox(chugin_page, wxID_ANY, "Enable ChuGins");
    chugin_page_sizer->Add(enable_chugins, 0, 
        wxTOP | wxLEFT | wxRIGHT | wxBOTTOM | wxALIGN_LEFT, 10);
    
    chugin_grid = new wxListCtrl(chugin_page, mAID_PREFS_CHUGIN_GRID, 
        wxDefaultPosition, wxDefaultSize, 
        wxLC_REPORT | wxLC_NO_HEADER | wxLC_HRULES | wxLC_EDIT_LABELS );
    chugin_grid->InsertColumn( 0, _T("chugin"), wxLIST_FORMAT_LEFT, 268 );

    chugin_page_sizer->Add(chugin_grid, 1, 
        wxEXPAND | wxLEFT | wxRIGHT | wxBOTTOM, 10);

    chugin_page->SetSizer(chugin_page_sizer);
    chugin_page->Fit();

    chugin_grid->SetMaxSize( chugin_grid->GetSize() );

    Connect( mAID_PREFS_CHUGIN_GRID, wxEVT_COMMAND_LIST_END_LABEL_EDIT,
        wxListEventHandler( mAPreferencesWindow::OnChuGinGridChange ) );
    Connect( mAID_PREFS_CHUGIN_GRID, wxEVT_COMMAND_LIST_KEY_DOWN,
        wxListEventHandler( mAPreferencesWindow::OnChuGinGridKeyDown ) );


    /*** create/populate the miscellaneous page of the notebook ***/
    misc_page = new wxPanel( notebook );
    notebook->AddPage( misc_page, _T( "Miscellaneous" ) );

    wxBoxSizer * misc_page_top = new wxBoxSizer( wxVERTICAL );
    wxSizer * misc_page_sizers[2];

    // current directory
    // allocate row 0 of misc_page
    misc_page_sizers[0] = new wxBoxSizer( wxHORIZONTAL );
    
    // current directory label
    wxStaticText * current_directory_label = new wxStaticText( misc_page, wxID_ANY,
                                                               _T( "Current Directory:" ),
                                                               wxDefaultPosition,
                                                               wxSize( 100, 20 ) );
    misc_page_sizers[0]->Add( current_directory_label,
                              2, wxALIGN_CENTER_VERTICAL );

    misc_page_sizers[0]->AddStretchSpacer();
    
    // current directory select button
    misc_page_sizers[0]->Add( new wxButton( misc_page, mAID_PREFS_CHOOSE_CWD,
                                            _T( "Select..." ) ), 
                              0, wxALIGN_CENTER_VERTICAL );
    Connect( mAID_PREFS_CHOOSE_CWD, wxEVT_COMMAND_BUTTON_CLICKED,
             wxCommandEventHandler( mAPreferencesWindow::OnChooseCurrentDirectory ) );

    //
    misc_page_top->Add( misc_page_sizers[0], 0, 
                        wxTOP | wxRIGHT | wxLEFT | wxBOTTOM | wxEXPAND, 10 );

    cwd_display = new wxTextCtrl( misc_page, wxID_ANY, wxGetHomeDir(),
                                  wxDefaultPosition, wxDefaultSize, wxTE_READONLY );
    misc_page_top->Add( cwd_display, 0, 
                        wxRIGHT | wxLEFT | wxBOTTOM | wxEXPAND, 10 );

    misc_page_top->Add( new wxStaticText( misc_page, wxID_ANY, 
                                          _T( "Relative filenames in ChucK programs (used in SndBuf, WvIn, and WvOut, for example) will be interpreted relative to this directory." ),
                                          wxDefaultPosition, cwd_display->GetSize() ),
                        1, wxEXPAND | wxRIGHT | wxLEFT | wxBOTTOM, 10 );

    //
    misc_page_top->AddStretchSpacer();

    //
    misc_page->SetSizer( misc_page_top );
    misc_page->Fit();
    
    // arrange the "restore defaults"/"OK"/"Cancel" buttons
    wxBoxSizer * ok_cancel = new wxBoxSizer( wxHORIZONTAL );

    ok_cancel->Add( new wxButton( this, wxID_DEFAULT, 
                                  _T( "Restore Defaults" ) ) );

    ok_cancel->AddStretchSpacer();

#ifdef __WINDOWS_DS__
    ok = new wxButton( this, wxID_OK, _T( "OK" ) );
    ok_cancel->Add( ok, 0, wxLEFT | wxRIGHT, 10 );

    ok_cancel->Add( new wxButton( this, wxID_CANCEL, _T( "Cancel" ) ) );
#else
    ok_cancel->Add( new wxButton( this, wxID_CANCEL, _T( "Cancel" ) ) );

    ok = new wxButton( this, wxID_OK, _T( "OK" ) );
    ok_cancel->Add( ok, 0, wxLEFT | wxRIGHT, 10 );
#endif

    top->Add( ok_cancel, 0, wxEXPAND | wxBOTTOM | wxRIGHT | wxLEFT, 10 );

    // set window sizer
    SetSizer( top );

    // set the window size to the minimum possible
    top->Fit( this );
    
    Connect( wxID_ANY, wxEVT_CLOSE_WINDOW, 
        wxCloseEventHandler( mAPreferencesWindow::OnClose ) );
    Connect( wxID_OK, wxEVT_COMMAND_BUTTON_CLICKED,
        wxCommandEventHandler( mAPreferencesWindow::OnOk ) );
    Connect( wxID_CANCEL, wxEVT_COMMAND_BUTTON_CLICKED,
        wxCommandEventHandler( mAPreferencesWindow::OnCancel ) );
    Connect( wxID_DEFAULT, wxEVT_COMMAND_BUTTON_CLICKED,
        wxCommandEventHandler( mAPreferencesWindow::OnRestoreDefaults ) );

    LoadPreferencesToGUI();
    ProbeAudioDevices();
    
    // HACK
    // TODO: separate LoadPreferencesToMiniAudicle function
    std::list< std::string > library_paths;
    for( std::vector< ChuGinPath >::iterator icps = chugin_paths.begin();
         icps != chugin_paths.end(); icps++ )
    {
        library_paths.push_back( std::string( (*icps).path.c_str() ) );
    }
    ma->set_library_paths( library_paths );
}

mAPreferencesWindow::~mAPreferencesWindow()
{
    delete font;
}

void mAPreferencesWindow::OnPreferencesCommand( wxCommandEvent & event )
{
    Show();
    Raise();
    ok->SetFocus();
}

void mAPreferencesWindow::OnClose( wxCloseEvent & event )
{
    if( event.CanVeto() )
    {
        event.Veto();
        Hide();
    }
    else
        Destroy();
}

void mAPreferencesWindow::OnOk( wxCommandEvent & event )
{
    Hide();
    LoadGUIToMiniAudicleAndPreferences();
}

void mAPreferencesWindow::OnCancel( wxCommandEvent & event )
{
    Hide();
    LoadPreferencesToGUI();
}

void mAPreferencesWindow::OnRestoreDefaults( wxCommandEvent & event )
{
    wxConfigBase * config = wxConfigBase::Get();
    
    // delete everything
    config->DeleteAll();
    
    // load to GUI, using defaults where necessary
    LoadPreferencesToGUI();
}

void mAPreferencesWindow::OnChooseFont( wxCommandEvent & event )
{
    font_dialog_data.SetInitialFont( *font );
    font_dialog_data.EnableEffects( false );
    font_dialog_data.SetAllowSymbols( false );

    wxFontDialog font_dialog( this, font_dialog_data );
    if( font_dialog.ShowModal() == wxID_OK )
    {
        font_dialog_data = font_dialog.GetFontData();
        wxString t_string;
        *font = font_dialog_data.GetChosenFont();
        wxString face_name = font->GetFaceName();
        int point_size = font->GetPointSize();
        t_string.Append( face_name ).Append( _T( " - " ) ).Append( wxString::Format( _T( "%i" ), point_size) ).Append( _T( " pt" ) );
        font_display->SetValue( t_string );
    }
}

void mAPreferencesWindow::OnSelectSyntaxColoringItem( wxCommandEvent & event )
{
    long color = colors[color_items->GetStringSelection()];
    color_button->SetBackgroundColour( wxColor( ( color >> 16 ) & 0xff, 
                                                ( color >> 8 ) & 0xff, 
                                                ( color ) & 0xff  ) );

}

void mAPreferencesWindow::OnChooseSyntaxColor( wxCommandEvent & event )
{
    wxColour new_color = wxGetColourFromUser( this, color_button->GetBackgroundColour() );

    if( new_color.Ok() )
    {
        color_button->SetBackgroundColour( new_color );
        long color = ( new_color.Red() << 16 ) | 
                     ( new_color.Green() << 8 ) | 
                     ( new_color.Blue() );
        colors[color_items->GetStringSelection()] = color;
        
        sc_changed = true;
    }
}

void mAPreferencesWindow::OnChooseCurrentDirectory( wxCommandEvent & event )
{
    wxString new_cwd = wxDirSelector( _T( "Choose Current Directory" ), 
                                      cwd_display->GetValue() );
    if( !new_cwd.empty() )
        cwd_display->SetValue( new_cwd );
}

void mAPreferencesWindow::OnProbeAudioDevices( wxCommandEvent & event )
{
    this->ProbeAudioDevices();
}

void mAPreferencesWindow::ProbeAudioDevices()
{
    wxConfigBase * config = wxConfigBase::Get();

    ma->probe();
    
    const vector< RtAudioDeviceInfo > & interfaces = ma->get_interfaces();
    vector< RtAudioDeviceInfo >::size_type i, len = interfaces.size();
    
    audio_output->Clear();
    audio_input->Clear();

    int dac;
    config->Read( mAPreferencesAudioOutput, &dac, 0 );
    int adc;
    config->Read( mAPreferencesAudioInput, &adc, 0 );
        
    // load available audio I/O interfaces into the pop up menus
    for( i = 0; i < len; i++ )
    {
        if( interfaces[i].outputChannels > 0 || interfaces[i].duplexChannels > 0 )
        {
            audio_output->Append( wxString( interfaces[i].name.c_str(), 
                                            wxConvUTF8 ), 
                                  ( void * ) ( i + 1 ) );
            if( i + 1 == dac )
                audio_output->SetSelection( audio_output->GetCount() - 1 );
        }

        if( interfaces[i].inputChannels > 0 || interfaces[i].duplexChannels > 0 )
        {
            audio_input->Append( wxString( interfaces[i].name.c_str(), 
                                           wxConvUTF8 ), 
                                 ( void * ) ( i + 1 ) );
            if( i + 1 == adc )
                audio_input->SetSelection( audio_input->GetCount() - 1 );
        }
    }
    
    if( dac == 0 )
        audio_output->SetSelection( 0 );
    if( adc == 0 )
        audio_input->SetSelection( 0 );
    
    this->SelectedAudioInputChanged();
    this->SelectedAudioOutputChanged();
}

void mAPreferencesWindow::SelectedAudioOutputChanged()
{
    wxConfigBase * config = wxConfigBase::Get();

    output_channels->Clear();   
    sample_rate->Clear();
    
    const vector< RtAudioDeviceInfo > & interfaces = ma->get_interfaces();

    int selected_output_item = audio_output->GetSelection();

    if( selected_output_item == wxNOT_FOUND )
        return;
    
    vector< RtAudioDeviceInfo >::size_type selected_output = ( vector< RtAudioDeviceInfo >::size_type ) audio_output->GetClientData( selected_output_item ) - 1;
    
    vector< int >::size_type j, sr_len = interfaces[selected_output].sampleRates.size();
    
    // load available sample rates into the pop up menu
    int default_sample_rate;
    config->Read( mAPreferencesSampleRate, &default_sample_rate, SAMPLING_RATE_DEFAULT );
    for( j = 0; j < sr_len; j++ )
    {
        sample_rate->Append( wxString::Format( _T( "%i" ), 
                                               interfaces[selected_output].sampleRates[j] ),
                             ( void * ) interfaces[selected_output].sampleRates[j] );
        
        // select the default sample rate
        if( interfaces[selected_output].sampleRates[j] == default_sample_rate )
            sample_rate->SetSelection( j );
    }

    if( sample_rate->GetSelection() == wxNOT_FOUND )
        sample_rate->SetSelection( sample_rate->GetCount() - 1 );
    
    // load available numbers of channels into respective pop up buttons
    int k, num_channels;
    
    num_channels = interfaces[selected_output].outputChannels;
    for( k = 0; k < num_channels; k++ )
        output_channels->Append( wxString::Format( _T( "%i" ), k + 1 ),
                                 ( void * ) ( k + 1 ) );
    
    int default_output_channels;
    config->Read( mAPreferencesOutputChannels, &default_output_channels, -1 );
    if( default_output_channels == -1 || default_output_channels > num_channels )
        /* default is to use as many channels as possible */
        output_channels->SetSelection( output_channels->GetCount() - 1 );
    else
        output_channels->SetSelection( default_output_channels - 1 );   
}

void mAPreferencesWindow::OnSelectedAudioOutputChanged( wxCommandEvent & event )
{
    this->SelectedAudioOutputChanged();
}

void mAPreferencesWindow::SelectedAudioInputChanged()
{
    wxConfigBase * config = wxConfigBase::Get();

    input_channels->Clear();   
    
    const vector< RtAudioDeviceInfo > & interfaces = ma->get_interfaces();

    int selected_input_item = audio_input->GetSelection();

    if( selected_input_item == wxNOT_FOUND )
        return;
    
    vector< RtAudioDeviceInfo >::size_type selected_input = ( vector< RtAudioDeviceInfo >::size_type ) audio_input->GetClientData( selected_input_item ) - 1;
    
    // load available numbers of channels into respective pop up buttons
    int k, num_channels;
    
    num_channels = interfaces[selected_input].inputChannels;
    for( k = 0; k < num_channels; k++ )
        input_channels->Append( wxString::Format( _T( "%i" ), k + 1 ),
                                 ( void * ) ( k + 1 ) );
    
    int default_input_channels;
    config->Read( mAPreferencesInputChannels, &default_input_channels, -1 );
    if( default_input_channels == -1 || default_input_channels > num_channels )
        /* default is to use as many channels as possible */
        input_channels->SetSelection( input_channels->GetCount() - 1 );
    else
        input_channels->SetSelection( default_input_channels - 1 );   
}

void mAPreferencesWindow::OnSelectedAudioInputChanged( wxCommandEvent & event )
{
    this->SelectedAudioInputChanged();
}


void mAPreferencesWindow::OnChuGinGridChange( wxListEvent & event )
{
    //fprintf( stderr, "WTF\n" );
    int row = event.GetIndex();
    wxString value = event.GetLabel();

    if( value.Length() > 0 )
    {
        // TODO: what if path contains the path separator character?
        if( row >= chugin_paths.size() )
        {
            // new path
            ChuGinPath cp;
            cp.type = ChuGinPath::DIRECTORY_TYPE; // TODO: figure this out for real
            cp.path = value;
            chugin_paths.push_back( cp );

            chugin_grid->InsertItem( chugin_grid->GetItemCount(), _T("") );
        }
        else
        {
            chugin_paths[row].path = value;
        }
    }
    else if( row < chugin_paths.size() )
    {
        // reset value if the string is empty
        chugin_grid->SetItemText( row, chugin_paths[row].path );
    }
}

void mAPreferencesWindow::OnChuGinGridKeyDown( wxListEvent & event )
{
    int keycode = event.GetKeyCode();
    if( chugin_grid->GetSelectedItemCount() > 0 && 
        ( keycode == WXK_DELETE || keycode == WXK_BACK || keycode == WXK_NUMPAD_DELETE ) )
    {
        long item = 0;
        while( ( item = chugin_grid->GetNextItem( item-1, wxLIST_NEXT_ALL, wxLIST_STATE_SELECTED ) ) != -1 )
        {
            chugin_grid->DeleteItem( item );
            chugin_paths.erase( chugin_paths.begin() + item );
        }
    }
    else
    {
        event.Skip();
    }
}


void mAPreferencesWindow::LoadPreferencesToGUI()
// assumes command line preferences have already been parsed
{
    wxConfigBase * config = wxConfigBase::Get();

    wxString str;
    long l;
    bool b;
    int i;
    int len;
    
    config->Read( mAPreferencesEnableAudio, &b, true );
    enable_audio->SetValue( b );
    
    config->Read( mAPreferencesEnableNetwork, &b, false );
    enable_network->SetValue( b );
    
    config->Read( mAPreferencesBufferSize, &l, BUFFER_SIZE_DEFAULT );
    for( i = 0, len = buffer_size->GetCount(); i < len; i++ )
    {
        if( ( ( long ) buffer_size->GetClientData( i ) ) == l )
        {
            buffer_size->SetSelection( i );
            break;
        }
    }
    
    config->Read( mAPreferencesFontName, &str, 
                  wxFont( 10, wxFONTFAMILY_MODERN, wxNORMAL, 
                          wxFONTWEIGHT_NORMAL ).GetFaceName() );
    config->Read( mAPreferencesFontSize, &l, 11 );
    wxString t_string;
    t_string.Append( str ).Append( _T( " - " ) ).Append( wxString::Format( _T( "%li" ), l ) ).Append( _T( " pt" ) );
    font_display->SetValue( t_string );

    if( font ) delete font;
    font = new wxFont( wxFont( l, wxFONTFAMILY_MODERN, wxNORMAL,
                               wxFONTWEIGHT_NORMAL, false, str ) );

    config->Read( mAPreferencesSyntaxColoringEnabled, &b, true );
    enable_coloring->SetValue( b );

    for( int j = 0; sc_tokens[j].key != NULL; j++ )
    {
        config->Read( *sc_tokens[j].key, &l, sc_tokens[j].color );
        colors[sc_tokens[j].name] = l;
    }

    long color = colors[color_items->GetStringSelection()];
    color_button->SetBackgroundColour( wxColor( ( color >> 16 ) & 0xff, 
                                                ( color >> 8 ) & 0xff, 
                                                ( color ) & 0xff  ) );
    
    sc_changed = false;

    config->Read( mAPreferencesUseTabs, &b, false );
    tab_key_tabs->SetValue( b );

    config->Read( mAPreferencesTabSize, &l, 4 );
    tab_size->SetValue( wxString::Format( _T( "%i" ), l ) );

    config->Read( mAPreferencesShowLineNumbers, &b, true );
    line_numbers->SetValue( b );
    
    str = wxGetHomeDir();
    config->Read( mAPreferencesCurrentDirectory, &str );
    cwd_display->SetValue( str );

    config->Read( mAPreferencesEnableChuGins, &b, true );
    enable_chugins->SetValue( b );

    config->Read( mAPreferencesChuGinPaths, &str, mAPreferencesDefaultChuGinPaths );
    chugin_paths.clear();
    DeserializeChuGinPaths( str, chugin_paths );

    len = chugin_paths.size();
    int num_rows = chugin_grid->GetItemCount();

    while( len + 1 > chugin_grid->GetItemCount() )
        chugin_grid->InsertItem( chugin_grid->GetItemCount(), _T("") );
    while( len + 1 < chugin_grid->GetItemCount() )
        chugin_grid->DeleteItem( chugin_grid->GetItemCount() - 1 );

    for( i = 0, len = chugin_paths.size(); i < len; i++ )
    {
        chugin_grid->SetItemText( i, chugin_paths[i].path );
    }
}

void mAPreferencesWindow::LoadGUIToMiniAudicleAndPreferences()
{
    wxConfigBase * config = wxConfigBase::Get();
    
    int selected_item;
    
    // enable audio
    config->Write( mAPreferencesEnableAudio, enable_audio->GetValue() );
    ma->set_enable_audio( enable_audio->GetValue() );
    
    // enable network
    config->Write( mAPreferencesEnableNetwork, enable_network->GetValue() );
    ma->set_enable_network_thread( enable_network->GetValue() );
    
    // dac
    selected_item = audio_output->GetSelection();
    if( selected_item != wxNOT_FOUND )
    {
        int dac = ( int ) audio_output->GetClientData( selected_item );
        config->Write( mAPreferencesAudioOutput, dac );
        ma->set_dac( dac );
    }
    
    // adc
    selected_item = audio_input->GetSelection();
    if( selected_item != wxNOT_FOUND )
    {
        int adc = ( int ) audio_input->GetClientData( selected_item );
        config->Write( mAPreferencesAudioInput, adc );
        ma->set_adc( adc );
    }
    
    // output channels
    selected_item = output_channels->GetSelection();
    if( selected_item != wxNOT_FOUND )
    {
        int num_outputs = ( int ) output_channels->GetClientData( selected_item );
        config->Write( mAPreferencesOutputChannels, num_outputs );
        ma->set_num_outputs( num_outputs );
    }
    
    // input channels
    selected_item = input_channels->GetSelection();
    if( selected_item != wxNOT_FOUND )
    {
        int num_inputs = ( int ) input_channels->GetClientData( selected_item );
        config->Write( mAPreferencesInputChannels, num_inputs );
        ma->set_num_inputs( num_inputs );
    }
    
    // sample rate
    selected_item = sample_rate->GetSelection();
    if( selected_item != wxNOT_FOUND )
    {
        int _sample_rate = ( int ) sample_rate->GetClientData( selected_item );
        config->Write( mAPreferencesSampleRate, _sample_rate );
        ma->set_sample_rate( _sample_rate );
    }
    
    // buffer size
    selected_item = buffer_size->GetSelection();
    if( selected_item != wxNOT_FOUND )
    {
        int _buffer_size = ( int ) buffer_size->GetClientData( selected_item );
        config->Write( mAPreferencesBufferSize, _buffer_size );
        ma->set_buffer_size( _buffer_size );
    }
    
    // font name
    wxString face_name = font->GetFaceName();
    config->Write( mAPreferencesFontName, face_name );
    
    // font size
    int point_size = font->GetPointSize();
    config->Write( mAPreferencesFontSize, point_size );
    
    // coloring enabled
    config->Write( mAPreferencesSyntaxColoringEnabled, enable_coloring->GetValue() );
    
    // colors
    for( int i = 0; sc_tokens[i].key != NULL; i++ )
        config->Write( *sc_tokens[i].key, colors[sc_tokens[i].name] );
        
    // tab key tabs
    config->Write( mAPreferencesUseTabs, tab_key_tabs->GetValue() );
    
    // tab width
    long _tab_size;
    if( tab_size->GetValue().ToLong( &_tab_size ) )
    {
        config->Write( mAPreferencesTabSize, _tab_size );
    }

    // line number
    config->Write( mAPreferencesShowLineNumbers, line_numbers->GetValue() );

    if( sc_changed )
    {
        wxGetApp().SyntaxColoringPreferencesChanged();
        sc_changed = false;
    }
    
    wxGetApp().EditingPreferencesChanged();
    
    // current directory
    config->Write( mAPreferencesCurrentDirectory, cwd_display->GetValue() );
    wxSetWorkingDirectory( cwd_display->GetValue() );

    // enable chugins
    config->Write( mAPreferencesEnableChuGins, enable_chugins->GetValue() );

    // chugin paths
    wxString pathstr;
    SerializeChuGinPaths( pathstr, chugin_paths );
    config->Write( mAPreferencesChuGinPaths, pathstr );

    std::list< std::string > library_paths;
    for( std::vector< ChuGinPath >::iterator icps = chugin_paths.begin();
         icps != chugin_paths.end(); icps++ )
    {
        library_paths.push_back( std::string( (*icps).path.c_str() ) );
    }
    ma->set_library_paths( library_paths );
}



