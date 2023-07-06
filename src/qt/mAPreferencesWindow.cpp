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
// file: mAPreferencesWindow.cpp
// desc: implementation for miniAudicle preferences
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
// date: 2005-present
//-----------------------------------------------------------------------------
#include <QFileDialog>
#include <QtWidgets/QStyleFactory>

#include <vector>
#include <string>
#include <list>

#include "miniAudicle.h"
#include "mAPreferencesWindow.h"
#include "ui_mAPreferencesWindow.h"
#include "ZSettings.h"
#include "chuck.h"
#include "chuck_dl.h"
#include "chuck_audio.h"
#include "chuck_errmsg.h"
#include "util_string.h"
using namespace std;


//-----------------------------------------------------------------------------
// keys for various settings
//-----------------------------------------------------------------------------
const QString mAPreferencesParentFrameWidth = "/GUI/ParentFrame/width";
const QString mAPreferencesParentFrameHeight = "/GUI/ParentFrame/height";
const QString mAPreferencesParentFrameX = "/GUI/ParentFrame/x";
const QString mAPreferencesParentFrameY = "/GUI/ParentFrame/y";
const QString mAPreferencesParentFrameMaximize = "/GUI/ParentFrame/maximize";
const QString mAPreferencesVMMonitorWidth = "/GUI/VMMonitor/width";
const QString mAPreferencesVMMonitorHeight = "/GUI/VMMonitor/height";
const QString mAPreferencesVMMonitorX = "/GUI/VMMonitor/x";
const QString mAPreferencesVMMonitorY = "/GUI/VMMonitor/y";
const QString mAPreferencesVMMonitorMaximize = "/GUI/VMMonitor/maximize";
const QString mAPreferencesConsoleMonitorWidth = "/GUI/ConsoleMonitor/width";
const QString mAPreferencesConsoleMonitorHeight = "/GUI/ConsoleMonitor/height";
const QString mAPreferencesConsoleMonitorX = "/GUI/ConsoleMonitor/x";
const QString mAPreferencesConsoleMonitorY = "/GUI/ConsoleMonitor/y";
const QString mAPreferencesConsoleMonitorMaximize = "/GUI/ConsoleMonitor/maximize";

const QString mAPreferencesFontName = "/GUI/Editing/FontName";
const QString mAPreferencesFontSize = "/GUI/Editing/FontSize";

const QString mAPreferencesSyntaxColoringEnabled = "/GUI/Editing/SyntaxColoringEnabled";
const QString mAPreferencesSyntaxColoringNormalText = "/GUI/Editing/SyntaxColoring/NormalText";
const QString mAPreferencesSyntaxColoringKeywords = "/GUI/Editing/SyntaxColoring/Keywords";
const QString mAPreferencesSyntaxColoringUGens = "/GUI/Editing/SyntaxColoring/UGens";
const QString mAPreferencesSyntaxColoringClasses = "/GUI/Editing/SyntaxColoring/Classes";
const QString mAPreferencesSyntaxColoringComments = "/GUI/Editing/SyntaxColoring/Comments";
const QString mAPreferencesSyntaxColoringStrings = "/GUI/Editing/SyntaxColoring/Strings";
const QString mAPreferencesSyntaxColoringNumbers = "/GUI/Editing/SyntaxColoring/Numbers";
const QString mAPreferencesSyntaxColoringBackground = "/GUI/Editing/SyntaxColoring/Background";

const QString mAPreferencesUseTabs = "/GUI/Editing/UsesTabs";
const QString mAPreferencesTabSize = "/GUI/Editing/TabSize";
const QString mAPreferencesShowLineNumbers = "/GUI/Editing/ShowLineNumbers";
const QString mAPreferencesWindowingStyle = "/GUI/Editing/WindowingStyle"; // 1.5.0.4 (ge) added

const QString mAPreferencesCurrentDirectory = "/Miscellaneous/CurrentDirectory";

const QString mAPreferencesEnableChuGins = "/ChuGins/Enable";
const QString mAPreferencesChuGinPaths = "/ChuGins/Paths";

const QString mAPreferencesAudioOutput = "/VM/DAC";
const QString mAPreferencesAudioInput = "/VM/ADC";
const QString mAPreferencesOutputChannels = "/VM/OutputChannels";
const QString mAPreferencesInputChannels = "/VM/InputChannels";
const QString mAPreferencesSampleRate = "/VM/SampleRate";
const QString mAPreferencesBufferSize = "/VM/SampleBufferSize";
const QString mAPreferencesVMStallTimeout = "/VM/StallTimeout";
const QString mAPreferencesAudioDriver = "/VM/AudioDriver"; // 1.5.0.1 (ge) added

const QString mAPreferencesEnableNetwork = "/VM/EnableNetworkOTFCommands";
const QString mAPreferencesEnableAudio = "/VM/EnableAudio";




//-----------------------------------------------------------------------------
// name: mAPreferencesWindow()
// desc: constructor
//-----------------------------------------------------------------------------
mAPreferencesWindow::mAPreferencesWindow( QWidget * parent, miniAudicle * ma)
    : QDialog(parent), ui(new Ui::mAPreferencesWindow), m_ma(ma), m_initializingComboBoxes(false)
{
    // set up the GUI aspect of the preferences windows
    ui->setupUi( this );

    // set dialog windows flags
    setWindowFlags(Qt::Window | Qt::WindowTitleHint | Qt::CustomizeWindowHint | Qt::WindowSystemMenuHint);

    m_colorDialog = NULL;

    // syntax colors
    m_indexToLabel.push_back("Normal Text"); m_indexToPref.push_back(mAPreferencesSyntaxColoringNormalText);
    m_indexToLabel.push_back("Keywords");    m_indexToPref.push_back(mAPreferencesSyntaxColoringKeywords);
    m_indexToLabel.push_back("Classes");     m_indexToPref.push_back(mAPreferencesSyntaxColoringClasses);
    m_indexToLabel.push_back("UGens");       m_indexToPref.push_back(mAPreferencesSyntaxColoringUGens);
    m_indexToLabel.push_back("Comments");    m_indexToPref.push_back(mAPreferencesSyntaxColoringComments);
    m_indexToLabel.push_back("Strings");     m_indexToPref.push_back(mAPreferencesSyntaxColoringStrings);
    m_indexToLabel.push_back("Numbers");     m_indexToPref.push_back(mAPreferencesSyntaxColoringNumbers);
    m_indexToLabel.push_back("Background");  m_indexToPref.push_back(mAPreferencesSyntaxColoringBackground);
    m_indexToColor.resize(m_indexToLabel.size());
    // add
    for(int i = 0; i < m_indexToLabel.size(); i++)
        ui->syntaxColoringType->addItem(m_indexToLabel[i]);

    // load settings to GUI
    loadSettingsToGUI();

    // set to first tab
    ui->tabWidget->setCurrentIndex(0);

    // connect ComboBox to handler | could be done here; instead this is connected in mAPreferencesWindow.ui
    // connect( ui->audioDriver, SIGNAL(currentIndexChanged(int)), this, SLOT(selectedAudioDriverChanged()) );
}


//-----------------------------------------------------------------------------
// name: ~mAPreferencesWindow()
// desc: destructor
//-----------------------------------------------------------------------------
mAPreferencesWindow::~mAPreferencesWindow()
{
    CK_SAFE_DELETE( ui );
}


//-----------------------------------------------------------------------------
// name: configureDefaults()
// desc: configure default settings
//-----------------------------------------------------------------------------
void mAPreferencesWindow::configureDefaults()
{
    ZSettings settings;

    ZSettings::setDefault(mAPreferencesEnableAudio, true);
    ZSettings::setDefault(mAPreferencesEnableNetwork, false);
    ZSettings::setDefault(mAPreferencesAudioOutput, 0);
    ZSettings::setDefault(mAPreferencesAudioInput, 0);
    ZSettings::setDefault(mAPreferencesSampleRate, CK_SAMPLE_RATE_DEFAULT);
    ZSettings::setDefault(mAPreferencesOutputChannels, 2);
    ZSettings::setDefault(mAPreferencesInputChannels, 2);
    ZSettings::setDefault(mAPreferencesBufferSize, CK_BUFFER_SIZE_DEFAULT);
    // 1.5.0.1 (ge) added -- default RtAudio::Api enum
    ZSettings::setDefault(mAPreferencesAudioDriver, (int)ChuckAudio::driverNameToApi(NULL));
    ZSettings::setDefault(mAPreferencesWindowingStyle, MA_WINDOWING_STYLE_DEFAULT );

    ZSettings::setDefault(mAPreferencesFontName, "Courier");
    ZSettings::setDefault(mAPreferencesFontSize, 10);

    ZSettings::setDefault(mAPreferencesSyntaxColoringEnabled, true);
    ZSettings::setDefault(mAPreferencesSyntaxColoringNormalText, qRgb(0x00, 0x00, 0x00));
    ZSettings::setDefault(mAPreferencesSyntaxColoringBackground, qRgb(0xFF, 0xFF, 0xFF));
    ZSettings::setDefault(mAPreferencesSyntaxColoringKeywords, qRgb(0x00, 0x00, 0xFF));
    ZSettings::setDefault(mAPreferencesSyntaxColoringClasses, qRgb(0x80, 0x00, 0x23));
    ZSettings::setDefault(mAPreferencesSyntaxColoringUGens, qRgb(0xA2, 0x00, 0xEC));
    ZSettings::setDefault(mAPreferencesSyntaxColoringComments, qRgb(0x60, 0x90, 0x10));
    ZSettings::setDefault(mAPreferencesSyntaxColoringStrings, qRgb(0x40, 0x40, 0x40));
    ZSettings::setDefault(mAPreferencesSyntaxColoringNumbers, qRgb(0xD4, 0x80, 0x10));

    ZSettings::setDefault(mAPreferencesUseTabs, false);
    ZSettings::setDefault(mAPreferencesTabSize, 4);
    // ZSettings::setDefault(mAPreferences)

    ZSettings::setDefault(mAPreferencesEnableChuGins, true);

    QStringList paths;

#ifdef __PLATFORM_WIN32__
    paths = QString(g_default_chugin_path).split(";");
    //paths.append(QCoreApplication::applicationDirPath() + "/ChuGins");
#else
    paths = QString(g_default_chugin_path).split(":");
#endif

    ZSettings::setDefault(mAPreferencesChuGinPaths, paths);
    ZSettings::setDefault(mAPreferencesCurrentDirectory, QDir::homePath());
}


//-----------------------------------------------------------------------------
// name: loadSettingsToGUI()
// desc: load settings to GUI
//-----------------------------------------------------------------------------
void mAPreferencesWindow::loadSettingsToGUI()
{
    ZSettings settings;

    // enable audio
    ui->enableAudio->setChecked(settings.get(mAPreferencesEnableAudio).toBool());
    // accept network VM commands
    ui->enableNetworkVM->setChecked(settings.get(mAPreferencesEnableNetwork).toBool());
    // selecte buffer size
    ui->bufferSize->setCurrentIndex(ui->bufferSize->findText(QString("%1").arg(settings.get(mAPreferencesBufferSize).toInt())));
    
    // audio driver selection | 1.5.0.1 (ge) added
    char buffer[128];
    // get driver from settings in the form of RtAudio::Api
    int driver = settings.get(mAPreferencesAudioDriver).toInt();
    // index of selected driver in the combobox
    int selectedDriverIndex = -1;

    // set state
    m_initializingComboBoxes = true;
    // clear to prevent double adding
    ui->audioDriver->clear();
    // populate the "Audio drivers" ComboBox
    for( unsigned int i = 0; i < ChuckAudio::numDrivers(); i++ )
    {
        ChuckAudioDriverInfo info = ChuckAudio::getDriverInfo(i);
        // add the item, with the Api enum as the associated data
        ui->audioDriver->addItem( info.userFriendlyName.c_str(), (int)info.driver );
        // check if match with driver read in from settings
        if( driver == info.driver ) selectedDriverIndex = i;
    }
    // set state
    m_initializingComboBoxes = false;

    // if the drivers from settings matched with an available driver
    if( selectedDriverIndex >= 0 )
    {
        // set the selection in the ComboBox
        ui->audioDriver->setCurrentIndex( selectedDriverIndex );
    }
    else // no match
    {
        // invalidate key from settings to reduce confusion
        // this should cause the defaults to be imposed
        settings.remove( mAPreferencesAudioDriver );
        settings.remove( mAPreferencesAudioOutput );
        settings.remove( mAPreferencesAudioInput );
        settings.remove( mAPreferencesInputChannels );
        settings.remove( mAPreferencesOutputChannels );
        settings.remove( mAPreferencesSampleRate );
        // set driver to default
        driver = (int)ChuckAudio::defaultDriverApi();
    }

    // sets GUI for audio input/output, num channels, and sample rate
    probeAudioDevices( driver );
    
    ui->font->setCurrentFont(QFont(settings.get(mAPreferencesFontName).toString()));
    ui->fontSize->setValue(settings.get(mAPreferencesFontSize).toInt());
    
    ui->enableSyntaxColoring->setChecked(settings.get(mAPreferencesSyntaxColoringEnabled).toBool());
    for(int i = 0; i < m_indexToColor.size(); i++)
        m_indexToColor[i] = QColor(settings.get(m_indexToPref[i]).toUInt());
    syntaxColoringTypeChanged();
   
    ui->editorUsesTabs->setChecked(settings.get(mAPreferencesUseTabs).toBool());
    ui->tabWidth->setValue(settings.get(mAPreferencesTabSize).toInt());
    
    ui->enableChugins->setChecked(settings.get(mAPreferencesEnableChuGins).toBool());
    ui->chuginsList->clear();
    QStringList chugins = settings.get(mAPreferencesChuGinPaths).toStringList();
    for(int i = 0; i < chugins.length(); i++)
    {
        QListWidgetItem * item = new QListWidgetItem(chugins[i]);
        item->setFlags(Qt::ItemIsEditable | Qt::ItemIsSelectable | Qt::ItemIsEnabled);
        ui->chuginsList->addItem(item);        
    }
    
    ui->currentDirectory->setText(settings.get(mAPreferencesCurrentDirectory).toString());

    // reset
    ui->styleComboBox->clear();

    // get style from settings
    string windowingStyle = settings.get(mAPreferencesWindowingStyle).toString().toStdString();

    // get and print available styles
    QStringList styles = QStyleFactory::keys();
    // set state
    m_initializingComboBoxes = true;
    // index for matching
    int selectedStyleIndex = -1;
    // counter
    int which = 0;
    // iterate over style names
    for(QStringList::Iterator s = styles.begin(); s != styles.end(); s++ )
    {
        // add name of style
        ui->styleComboBox->addItem( qUtf8Printable(*s), QString(qUtf8Printable(*s)) );
        // compare
        if( windowingStyle == string(qUtf8Printable(*s)) ) selectedStyleIndex = which;
        // increment
        which++;
    }
    // set state
    m_initializingComboBoxes = false;

    // check if match
    if( selectedStyleIndex >= 0 )
    {
        // set index
        ui->styleComboBox->setCurrentIndex( selectedStyleIndex );
        // just to be sure (seemingly, setCurrentIndex() doesn't always trigger the callback, e.g., on macOS)
        QApplication::setStyle( windowingStyle.c_str() );
    }
    else
    {
        // set to default, just to have something
        QApplication::setStyle( MA_WINDOWING_STYLE_DEFAULT );
    }
}


//-----------------------------------------------------------------------------
// name: loadGUIToSettings()
// desc: save settings from GUI
//-----------------------------------------------------------------------------
void mAPreferencesWindow::loadGUIToSettings()
{
    ZSettings settings;
    int i;
    
    settings.set(mAPreferencesEnableAudio, ui->enableAudio->isChecked());
    settings.set(mAPreferencesEnableNetwork, ui->enableNetworkVM->isChecked());
    
    // 1.5.0.1 (ge) added checks for empty ComboBoxes
    if( ui->audioDriver->currentIndex() >= 0 ) settings.set(mAPreferencesAudioDriver, ui->audioDriver->itemData(ui->audioDriver->currentIndex()));
    if( ui->audioOutput->currentIndex() >= 0 ) settings.set(mAPreferencesAudioOutput, ui->audioOutput->itemData(ui->audioOutput->currentIndex()));
    if( ui->audioInput->currentIndex() >= 0 ) settings.set(mAPreferencesAudioInput, ui->audioInput->itemData(ui->audioInput->currentIndex()));
    
    if( ui->inputChannels->currentIndex() >= 0 ) settings.set(mAPreferencesInputChannels, ui->inputChannels->itemData(ui->inputChannels->currentIndex()));
    if( ui->outputChannels->currentIndex() >= 0 ) settings.set(mAPreferencesOutputChannels, ui->outputChannels->itemData(ui->outputChannels->currentIndex()));
    if( ui->sampleRate->currentIndex() >= 0 ) settings.set(mAPreferencesSampleRate, ui->sampleRate->itemData(ui->sampleRate->currentIndex()));

    settings.set(mAPreferencesBufferSize, ui->bufferSize->currentText().toInt());
    settings.set(mAPreferencesFontName, ui->font->currentFont().family());
    settings.set(mAPreferencesFontSize, ui->fontSize->value());

    settings.set(mAPreferencesSyntaxColoringEnabled, ui->enableSyntaxColoring->isChecked());
    for(i = 0; i < m_indexToColor.size(); i++)
        settings.set(m_indexToPref[i], m_indexToColor[i].rgb());
    
    settings.set(mAPreferencesUseTabs, ui->editorUsesTabs->isChecked());
    settings.set(mAPreferencesTabSize, ui->tabWidth->value());

    settings.set(mAPreferencesEnableChuGins, ui->enableChugins->isChecked());
    QStringList paths;
    for(i = 0; i < ui->chuginsList->count(); i++)
    {
        paths.append(ui->chuginsList->item(i)->text());
    }
    settings.set(mAPreferencesChuGinPaths, paths);
    
    settings.set(mAPreferencesCurrentDirectory, ui->currentDirectory->text());
    QDir::setCurrent(settings.get(mAPreferencesCurrentDirectory).toString());

    // 1.5.0.4 (ge) added
    if( ui->styleComboBox->currentIndex() >= 0 ) settings.set( mAPreferencesWindowingStyle, ui->styleComboBox->itemData(ui->styleComboBox->currentIndex()));
}

void mAPreferencesWindow::ok()
{
    loadGUIToSettings();
    preferencesChanged();
    close();
}

void mAPreferencesWindow::cancel()
{
    loadSettingsToGUI();    
    close();
}

void mAPreferencesWindow::restoreDefaults()
{
    ZSettings settings;
    settings.clear();
    
    loadSettingsToGUI();
    preferencesChanged();    
}

void mAPreferencesWindow::probeAudioDevices( int driver, bool resetToDefault )
{
    ZSettings settings;

    // probe
    m_ma->probe( ChuckAudio::driverApiToName(driver) );
    
    const vector<RtAudio::DeviceInfo> & interfaces = m_ma->get_interfaces();
    vector<RtAudio::DeviceInfo>::size_type i, len = interfaces.size();

    ui->audioOutput->clear();
    ui->audioInput->clear();

    int dac = settings.get(mAPreferencesAudioOutput).toInt();
    int adc = settings.get(mAPreferencesAudioInput).toInt();
    
    // load available audio I/O interfaces into the pop up menus
    for(i = 0; i < len; i++)
    {
        // output
        if( interfaces[i].outputChannels > 0 || interfaces[i].duplexChannels > 0)
        {
            ui->audioOutput->addItem( interfaces[i].name.c_str(), int(i+1) );
            if( i+1 == dac )
                ui->audioOutput->setCurrentIndex(ui->audioOutput->count()-1);
            if( (resetToDefault || dac == 0) && interfaces[i].isDefaultOutput )
                ui->audioOutput->setCurrentIndex(ui->audioOutput->count()-1);
        }

        // input
        if( interfaces[i].inputChannels > 0 || interfaces[i].duplexChannels > 0 )
        {
            ui->audioInput->addItem( interfaces[i].name.c_str(), int(i+1) );
            if( i+1 == adc )
                ui->audioInput->setCurrentIndex(ui->audioInput->count()-1);
            if( (resetToDefault || adc == 0) && interfaces[i].isDefaultInput )
                ui->audioInput->setCurrentIndex(ui->audioInput->count()-1);
        }
    }

    // if( dac == 0 ) ui->audioOutput->setCurrentIndex( 0 );
    // if( adc == 0 ) ui->audioInput->setCurrentIndex( 0 );
    
    this->selectedAudioInputChanged();
    this->selectedAudioOutputChanged();
}


// 1.5.0.1 (ge) added
void mAPreferencesWindow::selectedAudioDriverChanged()
{
    // check state, as combobox initial addItem() implicitly triggers this callback (index going from -1 to 0)
    if( m_initializingComboBoxes ) return;
    // check if valid current index
    if( ui->audioDriver->currentIndex() < 0 ) return;

    // get driver enum from item data
    int driver = ui->audioDriver->itemData(ui->audioDriver->currentIndex()).toInt();
    // re-probe, forcing resetToDefault to select default audio output/input devices
    this->probeAudioDevices( driver, true );
}


void mAPreferencesWindow::selectedAudioOutputChanged()
{
    ZSettings settings;

    ui->outputChannels->clear();
    ui->sampleRate->clear();
    
    const vector<RtAudio::DeviceInfo> & interfaces = m_ma->get_interfaces();

    int selected_output_item = ui->audioOutput->currentIndex();

    if( selected_output_item == -1 )
        return;
    
    vector<RtAudio::DeviceInfo>::size_type selected_output = (vector< RtAudio::DeviceInfo >::size_type) ui->audioOutput->itemData(selected_output_item).toInt()-1;
    
    vector<int>::size_type j, sr_len = interfaces[selected_output].sampleRates.size();
    
    // load available sample rates into the pop up menu
    int default_sample_rate = settings.get(mAPreferencesSampleRate).toInt();
    for(j = 0; j < sr_len; j++)
    {
        ui->sampleRate->addItem(QString("%1").arg(interfaces[selected_output].sampleRates[j]),
                                interfaces[selected_output].sampleRates[j]);
        
        // select the default sample rate
        if(interfaces[selected_output].sampleRates[j] == default_sample_rate)
            ui->sampleRate->setCurrentIndex(j);
    }

    if( ui->sampleRate->currentIndex() == -1 )
        ui->sampleRate->setCurrentIndex(ui->sampleRate->count()-1);
    
    // load available numbers of channels into respective pop up buttons
    int k, num_channels;
    
    num_channels = interfaces[selected_output].outputChannels;
    for( k = 0; k < num_channels; k++ )
        ui->outputChannels->addItem(QString("%1").arg(k+1), k+1);
    
    int default_output_channels = settings.get(mAPreferencesOutputChannels).toInt();
    if(default_output_channels > num_channels)
        /* as many channels as possible */
        ui->outputChannels->setCurrentIndex(ui->outputChannels->count()-1);
    else
        ui->outputChannels->setCurrentIndex(default_output_channels-1);
}


void mAPreferencesWindow::selectedAudioInputChanged()
{
    ZSettings settings;

    ui->inputChannels->clear();
    
    const vector<RtAudio::DeviceInfo> & interfaces = m_ma->get_interfaces();

    int selected_input_item = ui->audioInput->currentIndex();

    if( selected_input_item == -1 )
        return;
    
    vector<RtAudio::DeviceInfo>::size_type selected_input = (vector<RtAudio::DeviceInfo>::size_type) ui->audioInput->itemData(selected_input_item).toInt()-1;
    
    // load available numbers of channels into respective pop up buttons
    int k, num_channels;
    
    num_channels = interfaces[selected_input].inputChannels;
    for( k = 0; k < num_channels; k++ )
        ui->inputChannels->addItem(QString("%1").arg(k+1), k+1);
    
    int default_input_channels = settings.get(mAPreferencesInputChannels).toInt();
    if(default_input_channels > num_channels)
        /* use as many channels as possible */
        ui->inputChannels->setCurrentIndex(ui->inputChannels->count()-1);
    else
        ui->inputChannels->setCurrentIndex(default_input_channels-1);
}


void mAPreferencesWindow::syntaxColoringTypeChanged()
{
    QColor color = m_indexToColor[ui->syntaxColoringType->currentIndex()];
    ui->syntaxColoringChangeButton->setStyleSheet("background: " + color.name());
}


void mAPreferencesWindow::syntaxColoringChangeColor()
{
    if(m_colorDialog == NULL)
    {
        m_colorDialog = new QColorDialog(this);
    }
    
    m_colorDialog->setCurrentColor(m_indexToColor[ui->syntaxColoringType->currentIndex()]);
    m_colorDialog->open(this, SLOT(syntaxColorChanged()));
}

void mAPreferencesWindow::syntaxColorChanged()
{
    QColor color = m_colorDialog->selectedColor();
    m_indexToColor[ui->syntaxColoringType->currentIndex()] = color;
    ui->syntaxColoringChangeButton->setStyleSheet("background: " + color.name());
}

void mAPreferencesWindow::addChugin()
{
    QListWidgetItem * item = new QListWidgetItem("");
    item->setFlags(Qt::ItemIsEditable | Qt::ItemIsSelectable | Qt::ItemIsEnabled);
    ui->chuginsList->addItem(item);
    ui->chuginsList->editItem(item);
}

void mAPreferencesWindow::removeChugin()
{
    qDeleteAll(ui->chuginsList->selectedItems());
}

void mAPreferencesWindow::probeChugins()
{
    // create a ChucK instance for probing
    ChucK * chuck = new ChucK();

    // remember log level
    t_CKINT logLevel = m_ma->get_log_level();

    // inherit system log level...
    chuck->setLogLevel( logLevel );

    // ensure log level is at least SYSTEM
    if( chuck->getLogLevel() < CK_LOG_SYSTEM ) chuck->setLogLevel( CK_LOG_SYSTEM );

    // enable chugins?
    bool chugin_load = ui->enableChugins->isChecked();

    // chugins search paths
    std::list<std::string> dl_search_path;
    // iterate over what's in the list
    for( int i = 0; i < ui->chuginsList->count(); i++ )
    {
        // append
        dl_search_path.push_back( ui->chuginsList->item(i)->text().toStdString() );
    }

    // set chugins parameters
    chuck->setParam( CHUCK_PARAM_CHUGIN_ENABLE, chugin_load );
    chuck->setParam( CHUCK_PARAM_USER_CHUGIN_DIRECTORIES, dl_search_path );
    // the_chuck->setParam( CHUCK_PARAM_USER_CHUGINS, named_dls );

    // signal
    probeChuginInitiated();

    // print
    EM_log( CK_LOG_SYSTEM, "-------( %s )-------", timestamp_formatted().c_str() );
    EM_log( CK_LOG_SYSTEM, "chugins probe diagnostic starting..." );

    // probe chugins (.chug and .ck modules)
    // print/log what ChucK would load with current settings
    chuck->probeChugins();

    // print
    EM_log( CK_LOG_SYSTEM, "-------( %s )-------", timestamp_formatted().c_str() );
    EM_log( CK_LOG_SYSTEM, "chugins probe diagnostic finished" );

    // suppress logging
    chuck->setLogLevel( CK_LOG_NONE );
    // clean up local instance
    CK_SAFE_DELETE( chuck );

    // restore to previous log level
    m_ma->set_log_level( logLevel );
}

void mAPreferencesWindow::changeCurrentDirectory()
{
    QFileDialog fileDialog(this);
    fileDialog.setFileMode(QFileDialog::Directory);
    fileDialog.setOption(QFileDialog::ShowDirsOnly, true);
    fileDialog.setDirectory(ui->currentDirectory->text());
    
    int ret = fileDialog.exec();
    
    if(ret == QDialog::Accepted)
    {
        ui->currentDirectory->setText(fileDialog.selectedFiles()[0]);
    }
}

// 1.5.0.4(ge) added
void mAPreferencesWindow::selectedWindowStyleChanged()
{
    // check state, as combobox initial addItem() implicitly triggers this callback (index going from -1 to 0)
    if( m_initializingComboBoxes ) return;
    // check if valid current index
    if( ui->styleComboBox->currentIndex() < 0 ) return;

    // get style name from item data
    string styleName = ui->styleComboBox->currentData().toString().toStdString();
    // set style byn name
    QApplication::setStyle( styleName.c_str() );
}

