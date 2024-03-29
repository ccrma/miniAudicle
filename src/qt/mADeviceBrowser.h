/*----------------------------------------------------------------------------
miniAudicle
GUI to ChucK audio programming environment

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
#ifndef MADEVICEBROWSER_H
#define MADEVICEBROWSER_H

#include <QtWidgets/QDialog>


namespace Ui {
class mADeviceBrowser;
}


class mADeviceBrowser : public QDialog
{
    Q_OBJECT
    
public:
    explicit mADeviceBrowser( QWidget * parent = 0 );
    ~mADeviceBrowser();
    
public slots:
    
    void showAudio();
    void showMIDI();
    void showHID();
    void selectedAudioDriverChanged();

private:
    // populate audio device info for a specific driver (e.g., DirectSound or Jack)
    void populateAudio( int driverApi );
    // state to prevent extra calls to populateAudio() when setting up audio driver combo box
    bool m_initializingDrivers;
    // cache the last selected audio driver
    int m_lastSelectedAudioDriver;

private:
    // the associate UI
    Ui::mADeviceBrowser * ui;
};

#endif // MADEVICEBROWSER_H
