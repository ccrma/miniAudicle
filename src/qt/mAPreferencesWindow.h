/*----------------------------------------------------------------------------
miniAudicle:
  integrated developement environment for ChucK audio programming language

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
// file: mAPreferencesWindow.h
// desc: header for miniAudicle preferences
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: 2005-present
//-----------------------------------------------------------------------------
#ifndef MAPREFERENCESWINDOW_H
#define MAPREFERENCESWINDOW_H

#include <QtWidgets/QDialog>
#include <QtWidgets/QColorDialog>
#include <vector>

namespace Ui {
class mAPreferencesWindow;
}


// forward reference
class miniAudicle;


//-----------------------------------------------------------------------------
// name: class mAPreferencesWindow
// desc: contoller for the preferences dialog window
//-----------------------------------------------------------------------------
class mAPreferencesWindow : public QDialog
{
    Q_OBJECT
    
public:
    // constructor
    explicit mAPreferencesWindow( QWidget * parent, miniAudicle * ma );
    // destructor
    ~mAPreferencesWindow();

public:
    // configure default settings
    static void configureDefaults();
    
public slots: // slots
    void ok();
    void cancel();
    void restoreDefaults();
    
    void probeAudioDevices( int driver, bool resetToDefault = false );
    void selectedAudioDriverChanged();
    void selectedAudioOutputChanged();
    void selectedAudioInputChanged();
    
    void syntaxColoringTypeChanged();
    void syntaxColoringChangeColor();
    void syntaxColorChanged();
    
    void addChugin();
    void removeChugin();
    
    void changeCurrentDirectory();
    void selectedWindowStyleChanged();
    
signals: // signals
    void preferencesChanged();
    
private:
    Ui::mAPreferencesWindow *ui;

    miniAudicle * m_ma;

    std::vector<QString> m_indexToLabel;
    std::vector<QString> m_indexToPref;
    std::vector<QColor> m_indexToColor;
    
    QColorDialog * m_colorDialog;

    // state to prevent extra calls to callbacks when setting up combo boxes
    bool m_initializingComboBoxes;

private:
    void loadSettingsToGUI();
    void loadGUIToSettings();
};


extern const QString mAPreferencesParentFrameWidth;
extern const QString mAPreferencesParentFrameHeight;
extern const QString mAPreferencesParentFrameX;
extern const QString mAPreferencesParentFrameY;
extern const QString mAPreferencesParentFrameMaximize;
extern const QString mAPreferencesVMMonitorWidth;
extern const QString mAPreferencesVMMonitorHeight;
extern const QString mAPreferencesVMMonitorX;
extern const QString mAPreferencesVMMonitorY;
extern const QString mAPreferencesVMMonitorMaximize;
extern const QString mAPreferencesConsoleMonitorWidth;
extern const QString mAPreferencesConsoleMonitorHeight;
extern const QString mAPreferencesConsoleMonitorX;
extern const QString mAPreferencesConsoleMonitorY;
extern const QString mAPreferencesConsoleMonitorMaximize;

extern const QString mAPreferencesFontName;
extern const QString mAPreferencesFontSize;

extern const QString mAPreferencesSyntaxColoringEnabled;
extern const QString mAPreferencesSyntaxColoringNormalText;
extern const QString mAPreferencesSyntaxColoringKeywords;
extern const QString mAPreferencesSyntaxColoringComments;
extern const QString mAPreferencesSyntaxColoringStrings;
extern const QString mAPreferencesSyntaxColoringNumbers;
extern const QString mAPreferencesSyntaxColoringBackground;
extern const QString mAPreferencesSyntaxColoringUGens;
extern const QString mAPreferencesSyntaxColoringClasses;

extern const QString mAPreferencesUseTabs;
extern const QString mAPreferencesTabSize;
extern const QString mAPreferencesShowLineNumbers;
extern const QString mAPreferencesWindowingStyle;

extern const QString mAPreferencesCurrentDirectory;

extern const QString mAPreferencesEnableChuGins;
extern const QString mAPreferencesChuGinPaths;

extern const QString mAPreferencesAudioOutput;
extern const QString mAPreferencesAudioInput;
extern const QString mAPreferencesAudioInput;
extern const QString mAPreferencesOutputChannels;
extern const QString mAPreferencesInputChannels;
extern const QString mAPreferencesSampleRate;
extern const QString mAPreferencesBufferSize;
extern const QString mAPreferencesAudioDriver;
extern const QString mAPreferencesVMStallTimeout;

extern const QString mAPreferencesEnableNetwork;
extern const QString mAPreferencesEnableAudio;

// default windowing style name | 1.5.0.4 (ge) added
#define MA_WINDOWING_STYLE_DEFAULT "Fusion"

#endif // MAPREFERENCESWINDOW_H
