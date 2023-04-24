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

#include "mAPreferencesWindow.h"
#include "ui_mAPreferencesWindow.h"

#include "miniAudicle.h"

#include "ZSettings.h"
#include <QFileDialog>

#include <vector>

#include "chuck_def.h"
#include "chuck_dl.h"
#include "chuck_audio.h"

using namespace std;

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

const QString mAPreferencesEnableNetwork = "/VM/EnableNetworkOTFCommands";
const QString mAPreferencesEnableAudio = "/VM/EnableAudio";


void mAPreferencesWindow::configureDefaults()
{
    ZSettings settings;
    
    ZSettings::setDefault(mAPreferencesEnableAudio, true);
    ZSettings::setDefault(mAPreferencesEnableNetwork, false);
    ZSettings::setDefault(mAPreferencesAudioOutput, 0);
    ZSettings::setDefault(mAPreferencesAudioInput, 0);
    ZSettings::setDefault(mAPreferencesSampleRate, SAMPLE_RATE_DEFAULT);
    ZSettings::setDefault(mAPreferencesOutputChannels, 2);
    ZSettings::setDefault(mAPreferencesInputChannels, 2);
    ZSettings::setDefault(mAPreferencesBufferSize, BUFFER_SIZE_DEFAULT);
    
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
//    ZSettings::setDefault(mAPreferences)
    
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

mAPreferencesWindow::mAPreferencesWindow(QWidget *parent, miniAudicle * ma) :
    QDialog(parent),
    ui(new Ui::mAPreferencesWindow),
    m_ma(ma)
{
    ui->setupUi(this);
    
    setWindowFlags(Qt::Window | Qt::WindowTitleHint | Qt::CustomizeWindowHint | Qt::WindowSystemMenuHint);
    
    m_colorDialog = NULL;
    
    m_indexToLabel.push_back("Normal Text"); m_indexToPref.push_back(mAPreferencesSyntaxColoringNormalText);
    m_indexToLabel.push_back("Keywords");    m_indexToPref.push_back(mAPreferencesSyntaxColoringKeywords);
    m_indexToLabel.push_back("Classes");     m_indexToPref.push_back(mAPreferencesSyntaxColoringClasses);
    m_indexToLabel.push_back("UGens");       m_indexToPref.push_back(mAPreferencesSyntaxColoringUGens);
    m_indexToLabel.push_back("Comments");    m_indexToPref.push_back(mAPreferencesSyntaxColoringComments);
    m_indexToLabel.push_back("Strings");     m_indexToPref.push_back(mAPreferencesSyntaxColoringStrings);
    m_indexToLabel.push_back("Numbers");     m_indexToPref.push_back(mAPreferencesSyntaxColoringNumbers);
    m_indexToLabel.push_back("Background");  m_indexToPref.push_back(mAPreferencesSyntaxColoringBackground);
    m_indexToColor.resize(m_indexToLabel.size());
    
    for(int i = 0; i < m_indexToLabel.size(); i++)
        ui->syntaxColoringType->addItem(m_indexToLabel[i]);
    
    loadSettingsToGUI();
    
    ui->tabWidget->setCurrentIndex(0);    
}

mAPreferencesWindow::~mAPreferencesWindow()
{
    delete ui;
}

void mAPreferencesWindow::loadSettingsToGUI()
{
    ZSettings settings;
    
    ui->enableAudio->setChecked(settings.get(mAPreferencesEnableAudio).toBool());
    ui->enableNetworkVM->setChecked(settings.get(mAPreferencesEnableNetwork).toBool());
    
    ui->bufferSize->setCurrentIndex(ui->bufferSize->findText(QString("%1").arg(settings.get(mAPreferencesBufferSize).toInt())));
    
    // sets GUI for audio input/output, num channels, and sample rate
    ProbeAudioDevices();
    
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
}

void mAPreferencesWindow::loadGUIToSettings()
{
    ZSettings settings;
    int i;    
    
    settings.set(mAPreferencesEnableAudio, ui->enableAudio->isChecked());
    settings.set(mAPreferencesEnableNetwork, ui->enableNetworkVM->isChecked());
    
    settings.set(mAPreferencesAudioOutput, ui->audioOutput->itemData(ui->audioOutput->currentIndex()));
    settings.set(mAPreferencesAudioInput, ui->audioInput->itemData(ui->audioInput->currentIndex()));
    
    settings.set(mAPreferencesInputChannels, ui->inputChannels->itemData(ui->inputChannels->currentIndex()));
    settings.set(mAPreferencesOutputChannels, ui->outputChannels->itemData(ui->outputChannels->currentIndex()));
    
    settings.set(mAPreferencesSampleRate, ui->sampleRate->itemData(ui->sampleRate->currentIndex()));
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

void mAPreferencesWindow::ProbeAudioDevices()
{
    ZSettings settings;

    m_ma->probe();
    
    const vector<RtAudio::DeviceInfo> & interfaces = m_ma->get_interfaces();
    vector<RtAudio::DeviceInfo>::size_type i, len = interfaces.size();
    
    ui->audioOutput->clear();
    ui->audioInput->clear();

    int dac = settings.get(mAPreferencesAudioOutput).toInt();
    int adc = settings.get(mAPreferencesAudioInput).toInt();
    
    // load available audio I/O interfaces into the pop up menus
    for(i = 0; i < len; i++)
    {
        if(interfaces[i].outputChannels > 0 || interfaces[i].duplexChannels > 0)
        {
            ui->audioOutput->addItem(interfaces[i].name.c_str(), int(i+1));
            if(i + 1 == dac)
                ui->audioOutput->setCurrentIndex(ui->audioOutput->count()-1);
            if(dac == 0 && interfaces[i].isDefaultOutput)
                ui->audioOutput->setCurrentIndex(ui->audioOutput->count()-1);
        }

        if(interfaces[i].inputChannels > 0 || interfaces[i].duplexChannels > 0)
        {
            ui->audioInput->addItem(interfaces[i].name.c_str(), int(i+1));
            if(i + 1 == adc)
                ui->audioInput->setCurrentIndex(ui->audioInput->count()-1);
            if(dac == 0 && interfaces[i].isDefaultInput)
                ui->audioOutput->setCurrentIndex(ui->audioInput->count()-1);            
        }
    }
    
//    if( dac == 0 )
//        ui->audioOutput->setCurrentIndex( 0 );
//    if( adc == 0 )
//        ui->audioInput->setCurrentIndex( 0 );
    
    this->SelectedAudioInputChanged();
    this->SelectedAudioOutputChanged();
}

void mAPreferencesWindow::SelectedAudioOutputChanged()
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

void mAPreferencesWindow::SelectedAudioInputChanged()
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


