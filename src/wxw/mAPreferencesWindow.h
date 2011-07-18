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
// file: mAPreferencesWindow.h
// desc: preferences window controller
//
// author: Spencer Salazar (ssalazar@cs.princeton.edu)
// date: Fall 2006
//-----------------------------------------------------------------------------

#ifndef __MA_PREFERENCES_WINDOW_H__
#define __MA_PREFERENCES_WINDOW_H__

#include "wx/wx.h"
#include "wx/listctrl.h"
#include "wx/grid.h"

#include <map>

class miniAudicle;

#ifdef __LINUX__
typedef wxFrame mAWindowSuper;      // frame super class
typedef wxWindow mAWindowParent;    // window parent object type
#else
typedef wxMDIChildFrame mAWindowSuper;   // frame super class
typedef wxMDIParentFrame mAWindowParent; // window parent object type
#endif


struct ChuGinPath
{
    enum Type
    {
        DIRECTORY_TYPE,
        CHUGIN_TYPE
    };

    ChuGinPath(Type _type=DIRECTORY_TYPE) :
        type(_type),
        path(wxEmptyString)
    {}
    
    ChuGinPath(Type _type, wxString & _path) :
        type(_type),
        path(_path)
    {}
    
    Type type;
    wxString path;
};


void DeserializeChuGinPaths(wxString pathstr, std::vector<ChuGinPath> & pathv);
void SerializeChuGinPaths(wxString & pathstr, std::vector<ChuGinPath> & pathv);


class mAPreferencesWindow : public mAWindowSuper
{
public:
    mAPreferencesWindow( miniAudicle * ma, mAWindowParent * parent, 
        wxWindowID id = wxID_ANY, 
        const wxString & title = _T( "Preferences" ), 
        const wxPoint & pos = wxDefaultPosition, 
        const wxSize & size = wxDefaultSize, 
        long style = wxDEFAULT_FRAME_STYLE & ~( wxMAXIMIZE_BOX | wxRESIZE_BORDER ) );
    ~mAPreferencesWindow();


    void OnPreferencesCommand( wxCommandEvent & event );
    void OnClose( wxCloseEvent & event );
    void OnOk( wxCommandEvent & event );
    void OnCancel( wxCommandEvent & event );
    void OnRestoreDefaults( wxCommandEvent & event );

    void OnChooseFont( wxCommandEvent & event );
    void OnSelectSyntaxColoringItem( wxCommandEvent & event );
    void OnChooseSyntaxColor( wxCommandEvent & event );
    void OnChooseCurrentDirectory( wxCommandEvent & event );

    void LoadPreferencesToGUI();
    void LoadGUIToMiniAudicleAndPreferences();
    
    void ProbeAudioDevices();
    void OnProbeAudioDevices( wxCommandEvent & event );
    void SelectedAudioOutputChanged();
    void OnSelectedAudioOutputChanged( wxCommandEvent & event );
    void SelectedAudioInputChanged();
    void OnSelectedAudioInputChanged( wxCommandEvent & event );

    void OnChuGinGridChange( wxListEvent & event );
    void OnChuGinGridKeyDown( wxListEvent & event );

protected:
    miniAudicle * ma;
    
    wxButton * ok;
    
    wxNotebook * notebook;

    // audio page
    wxPanel * audio_page;

    wxCheckBox * enable_audio;
    wxCheckBox * enable_network;

    wxChoice * audio_output;
    wxChoice * audio_input;

    wxChoice * input_channels;
    wxChoice * output_channels;

    wxChoice * sample_rate;
    wxChoice * buffer_size;

    // editing page
    wxPanel * editing_page;

    wxTextCtrl * font_display;
    wxFont * font;
    wxFontData font_dialog_data;
    
    wxCheckBox * enable_coloring;
    wxChoice * color_items;
    wxButton * color_button;
    std::map< wxString, long > colors;
    bool sc_changed;

    wxCheckBox * tab_key_tabs;
    wxTextCtrl * tab_size;

    wxCheckBox * line_numbers;
    
    // chugin page
    wxPanel * chugin_page;

    wxCheckBox * enable_chugins;
    wxListCtrl * chugin_grid;

    std::vector<ChuGinPath> chugin_paths;

    // miscellaneous page
    wxPanel * misc_page;

    wxTextCtrl * cwd_display;
};

extern const wxString mAPreferencesParentFrameWidth;
extern const wxString mAPreferencesParentFrameHeight;
extern const wxString mAPreferencesParentFrameX;
extern const wxString mAPreferencesParentFrameY;
extern const wxString mAPreferencesParentFrameMaximize;
extern const wxString mAPreferencesVMMonitorWidth;
extern const wxString mAPreferencesVMMonitorHeight;
extern const wxString mAPreferencesVMMonitorX;
extern const wxString mAPreferencesVMMonitorY;
extern const wxString mAPreferencesVMMonitorMaximize;
extern const wxString mAPreferencesConsoleMonitorWidth;
extern const wxString mAPreferencesConsoleMonitorHeight;
extern const wxString mAPreferencesConsoleMonitorX;
extern const wxString mAPreferencesConsoleMonitorY;
extern const wxString mAPreferencesConsoleMonitorMaximize;

extern const wxString mAPreferencesFontName;
extern const wxString mAPreferencesFontSize;

extern const wxString mAPreferencesSyntaxColoringEnabled;
extern const wxString mAPreferencesSyntaxColoringNormalText;
extern const wxString mAPreferencesSyntaxColoringKeywords;
extern const wxString mAPreferencesSyntaxColoringComments;
extern const wxString mAPreferencesSyntaxColoringStrings;
extern const wxString mAPreferencesSyntaxColoringNumbers;
extern const wxString mAPreferencesSyntaxColoringBackground;

extern const wxString mAPreferencesUseTabs;
extern const wxString mAPreferencesTabSize;
extern const wxString mAPreferencesShowLineNumbers;

extern const wxString mAPreferencesCurrentDirectory;

extern const wxString mAPreferencesEnableChuGins;
extern const wxString mAPreferencesChuGinPaths;

extern const wxString mAPreferencesAudioOutput;
extern const wxString mAPreferencesAudioInput;
extern const wxString mAPreferencesOutputChannels;
extern const wxString mAPreferencesInputChannels;
extern const wxString mAPreferencesSampleRate;
extern const wxString mAPreferencesBufferSize;
extern const wxString mAPreferencesVMStallTimeout;

extern const wxString mAPreferencesEnableNetwork;
extern const wxString mAPreferencesEnableAudio;

#endif // __MA_PREFERENCES_WINDOW_H__

