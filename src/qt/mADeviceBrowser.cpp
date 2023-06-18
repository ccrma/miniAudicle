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

#include "mADeviceBrowser.h"
#include "ui_mADeviceBrowser.h"

#include "RtAudio/RtAudio.h"
#include "rtmidi.h"
#include "util_rterror.h"
#include "hidio_sdl.h"
#include "chuck_audio.h"
#include "chuck_errmsg.h"

// #include <QDebug>


mADeviceBrowser::mADeviceBrowser(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::mADeviceBrowser),
    m_initializingDrivers(false),
    m_lastSelectedAudioDriver(-1)
{
    ui->setupUi(this);
    
    // set flags
    setWindowFlags(Qt::Window | Qt::WindowTitleHint | Qt::CustomizeWindowHint | Qt::WindowSystemMenuHint | Qt::WindowCloseButtonHint | Qt::WindowMinMaxButtonsHint);

    // configure tree widget
    ui->treeWidget->setColumnCount(2);
    ui->treeWidget->setColumnWidth(0, 144);
    
    // show default
    showAudio();
}


mADeviceBrowser::~mADeviceBrowser()
{
    SAFE_DELETE(ui);
}


void mADeviceBrowser::showAudio()
{
    // enable audio driver combo box
    ui->audioDriver->setEnabled(true);
    ui->audioDriverLabel->setEnabled(true);
    // highlight
    ui->audioButton->setDown(true);
    // clear the combo box, since device browser could be repeatedly called
    ui->audioDriver->clear();

    // debug; this variable can be tricky, since it gets set populateAudio(), which
    // can be called anytime Qt considers the combo box index changing
    // qDebug() << "showAudio() -- m_lastSelectedAudioDriver: " << m_lastSelectedAudioDriver;

    // copy from cached
    int driver = m_lastSelectedAudioDriver;
    // check last selected driver
    if( driver < 0 )
        driver = (int)ChuckAudio::defaultDriverApi();
    // index of selected driver in the combobox
    int selectedDriverIndex = -1;
    // state to prevent addItem from triggering populateAudio()
    m_initializingDrivers = true;
    // populate the "Audio drivers" ComboBox
    for( unsigned int i = 0; i < ChuckAudio::numDrivers(); i++ )
    {
        ChuckAudioDriverInfo info = ChuckAudio::getDriverInfo(i);
        // add the item, with the Api enum as the associated data
        ui->audioDriver->addItem( info.userFriendlyName.c_str(), (int)info.driver );
        // check if match with driver read in from settings
        if( driver == (int)info.driver ) selectedDriverIndex = i;
    }

    // if the drivers from settings matched with an available driver
    if( selectedDriverIndex >= 0 )
    {
        // set the selection in the ComboBox
        ui->audioDriver->setCurrentIndex( selectedDriverIndex );
    }
    else // no match
    {
        // if somehow not found, select the first one
        if( ChuckAudio::numDrivers() > 0 )
            ui->audioDriver->setCurrentIndex( 0 );
    }
    // state to prevent addItem from triggering populateAudio()
    m_initializingDrivers = false;

    // populate the audio info
    populateAudio( driver );
}


// 1.5.0.2 (ge) added
void mADeviceBrowser::populateAudio( int driverApi )
{
    // clear the info
    ui->treeWidget->clear();

    RtAudio * rta = NULL;
    RtAudio::DeviceInfo info;

    // allocate RtAudio
    rta = new RtAudio( (RtAudio::Api)driverApi, rtaudio_error );

    if( rtaudio_has_error() )
    {
        rtaudio_error_print(true);
        delete rta;
        return;
    }

    // cache this
    m_lastSelectedAudioDriver = driverApi;

    // get count
    int numDevices = rta->getDeviceCount();

    if( rtaudio_has_error() )
    {
        rtaudio_error_print(true);
        delete rta;
        return;
    }

    // loop
    for( int i = 1; i <= numDevices; i++ )
    {
        info = rta->getDeviceInfo( i - 1 );

        if( rtaudio_has_error() )
        {
            rtaudio_error_print(true);
            continue;
        }

        QStringList list;

        list.clear(); list.append(QString("%1").arg(i)); list.append(QString(info.name.c_str()));
        QTreeWidgetItem * deviceItem = new QTreeWidgetItem(list);

        list.clear(); list.append(QString("Output Channels")); list.append(QString("%1").arg(info.outputChannels));
        deviceItem->addChild(new QTreeWidgetItem(list));
        list.clear(); list.append(QString("Input Channels")); list.append(QString("%1").arg(info.inputChannels));
        deviceItem->addChild(new QTreeWidgetItem(list));
        list.clear(); list.append(QString("Duplex Channels")); list.append(QString("%1").arg(info.duplexChannels));
        deviceItem->addChild(new QTreeWidgetItem(list));

        QString sampleRates;
        for( int j = 0; j < info.sampleRates.size(); j++ )
        {
            if( j != 0 )
                sampleRates.append(", ");
            sampleRates.append(QString("%1").arg(info.sampleRates[j]));
        }
        list.clear(); list.append(QString("Sample Rates")); list.append(sampleRates);
        deviceItem->addChild(new QTreeWidgetItem(list));

        QString nativeFormats;

        if( info.nativeFormats & RTAUDIO_SINT8 )
        {
            if(nativeFormats.length() > 0 )
                nativeFormats.append(", ");
            nativeFormats.append("8-bit int");
        }

        if( info.nativeFormats & RTAUDIO_SINT16 )
        {
            if(nativeFormats.length() > 0 )
                nativeFormats.append(", ");
            nativeFormats.append("16-bit int");
        }

        if( info.nativeFormats & RTAUDIO_SINT24 )
        {
            if(nativeFormats.length() > 0 )
                nativeFormats.append(", ");
            nativeFormats.append("24-bit int");
        }

        if( info.nativeFormats & RTAUDIO_SINT32 )
        {
            if(nativeFormats.length() > 0 )
                nativeFormats.append(", ");
            nativeFormats.append("32-bit int");
        }

        if( info.nativeFormats & RTAUDIO_FLOAT32 )
        {
            if(nativeFormats.length() > 0 )
                nativeFormats.append(", ");
            nativeFormats.append("32-bit float");
        }

        if( info.nativeFormats & RTAUDIO_FLOAT64 )
        {
            if(nativeFormats.length() > 0 )
                nativeFormats.append(", ");
            nativeFormats.append("64-bit float");
        }

        list.clear(); list.append(QString("Native Formats")); list.append(nativeFormats);
        deviceItem->addChild(new QTreeWidgetItem(list));

        list.clear(); list.append(QString("Default Output")); list.append(QString(info.isDefaultOutput ? "yes" : "no"));
        deviceItem->addChild(new QTreeWidgetItem(list));
        list.clear(); list.append(QString("Default Input")); list.append(QString(info.isDefaultInput ? "yes" : "no"));
        deviceItem->addChild(new QTreeWidgetItem(list));

        ui->treeWidget->addTopLevelItem(deviceItem);
    }

    delete rta;

    ui->treeWidget->expandAll();
}


void mADeviceBrowser::showMIDI()
{
    // disable audio driver combo box
    ui->audioDriver->setEnabled(false);
    ui->audioDriverLabel->setEnabled(false);
    // highlight
    ui->midiButton->setDown(true);
    // clear info
    ui->treeWidget->clear();
    
    RtMidiIn * min = NULL;
    RtMidiOut * mout = NULL;
    
    try { min = new RtMidiIn; }
    catch( RtMidiError & err )
    {
        EM_error2b( 0, "%s", err.getMessage().c_str() );
        return;
    }

    QTreeWidgetItem *inputItem = new QTreeWidgetItem(QStringList(QString("Input")));
    
    t_CKUINT num = min->getPortCount();
    std::string s;
    for( t_CKUINT i = 0; i < num; i++ )
    {
        s = min->getPortName( i );
        
        QStringList list; list.append(QString("%1").arg(i)); list.append(QString(s.c_str()));
        inputItem->addChild(new QTreeWidgetItem(list));
    }
    
    delete min;
    
    QTreeWidgetItem *outputItem = new QTreeWidgetItem(QStringList(QString("Output")));
    
    try { mout = new RtMidiOut; }
    catch( RtMidiError & err )
    {
        EM_error2b( 0, "%s", err.getMessage().c_str() );
        return;
    }
    
    num = mout->getPortCount();
    for( t_CKUINT i = 0; i < num; i++ )
    {
        s = mout->getPortName( i );
        
        QStringList list; list.append(QString("%1").arg(i)); list.append(QString(s.c_str()));
        outputItem->addChild(new QTreeWidgetItem(list));
    }
    
    delete mout;
    
    ui->treeWidget->addTopLevelItem(inputItem);
    ui->treeWidget->addTopLevelItem(outputItem);
    
    ui->treeWidget->expandAll();    
}

void mADeviceBrowser::showHID()
{
    // disable audio driver combo box
    ui->audioDriver->setEnabled(false);
    ui->audioDriverLabel->setEnabled(false);
    // highlight
    ui->hidButton->setDown(true);
    // clear info
    ui->treeWidget->clear();
    
    HidInManager::init();

    for( size_t i = 0; i < CK_HID_DEV_COUNT; i++ )
    {
        if( !default_drivers[i].count )
            continue;
        
        int count = default_drivers[i].count();
        if( count == 0 )
            continue;
        
        QTreeWidgetItem *typeItem = new QTreeWidgetItem(QStringList(QString(default_drivers[i].driver_name)));
        
        for( int j = 0; j < count; j++ )
        {
            const char * name;
            if( default_drivers[i].name )
                name = default_drivers[i].name( j );
            if( !name )
                name = "(no name)";
            
            QStringList list; list.append(QString("%1").arg(j)); list.append(QString(name));
            typeItem->addChild(new QTreeWidgetItem(list));            
        }
        
        ui->treeWidget->addTopLevelItem(typeItem);
    }
    
    ui->treeWidget->expandAll();    
}


// 1.5.0.2 (ge) added
void mADeviceBrowser::selectedAudioDriverChanged()
{
    // check state, as combobox initial addItem() implicitly triggers this callback (index going from -1 to 0)
    if( m_initializingDrivers ) return;

    // check index, as this could be triggered when switching tabs, and before showAudio() is called, leading to unexpected m_lastSelectedAudioDriver values
    if( ui->audioDriver->currentIndex() < 0 ) return;

    // get driver enum from item data
    int driver = ui->audioDriver->itemData(ui->audioDriver->currentIndex()).toInt();

    // re-probe, forcing resetToDefault to select default audio output/input devices
    this->populateAudio( driver );
}
