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

#include "mAMainWindow.h"
#include "ui_mAMainWindow.h"

#include "madocumentview.h"
#include "mAConsoleMonitor.h"
#include "mAVMMonitor.h"
#include "mAPreferencesWindow.h"

#include <QMessageBox>
#include <QDesktopWidget>
#include "ZSettings.h"
#include <QCloseEvent>
#include <QPushButton>

#include <list>


extern const char MA_VERSION[];
extern const char MA_ABOUT[];
extern const char MA_HELP[];
extern const char CK_VERSION[];


const int MAX_RECENT_FILES = 10;


mAMainWindow::mAMainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::mAMainWindow),
    ma(new miniAudicle)
{
    ui->setupUi(this);

    vm_on = false;

    QCoreApplication::setOrganizationName("Stanford CCRMA");
    QCoreApplication::setOrganizationDomain("ccrma.stanford.edu");
    QCoreApplication::setApplicationName("miniAudicle");

    mAPreferencesWindow::configureDefaults();

    ZSettings settings;

    QDir::setCurrent(settings.get(mAPreferencesCurrentDirectory).toString());

    m_consoleMonitor = new mAConsoleMonitor(NULL);
    m_vmMonitor = new mAVMMonitor(NULL, this, ma);
    m_preferencesWindow = NULL;

    m_lockdown = false;

    m_docid = ma->allocate_document_id();

    ui->actionAdd_Shred->setEnabled(vm_on);
    ui->actionRemove_Shred->setEnabled(vm_on);
    ui->actionReplace_Shred->setEnabled(vm_on);
    ui->actionRemove_Last_Shred->setEnabled(vm_on);
    ui->actionRemove_All_Shreds->setEnabled(vm_on);
    ui->actionAdd_All_Open_Documents->setEnabled(vm_on);
    ui->actionReplace_All_Open_Documents->setEnabled(vm_on);
    ui->actionRemove_All_Open_Documents->setEnabled(vm_on);
    ui->actionAbort_Currently_Running_Shred->setEnabled(vm_on);

    updateRecentFilesMenu();

    ma->set_log_level(settings.get("/ChucK/LogLevel", (int) 2).toInt());
    switch(ma->get_log_level())
    {
    case 0: ui->actionLogNone->setChecked(true); break;
    case 1: ui->actionLogCore->setChecked(true); break;
    case 2: ui->actionLogSystem->setChecked(true); break;
    case 3: ui->actionLogSevere->setChecked(true); break;
    case 4: ui->actionLogWarning->setChecked(true); break;
    case 5: ui->actionLogInfo->setChecked(true); break;
    case 6: ui->actionLogConfig->setChecked(true); break;
    case 7: ui->actionLogFine->setChecked(true); break;
    case 8: ui->actionLogFiner->setChecked(true); break;
    case 9: ui->actionLogFinest->setChecked(true); break;
    case 10: ui->actionLogCrazy->setChecked(true); break;
    }

    QWidget * expandingSpace = new QWidget;
    expandingSpace->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Preferred);
    ui->mainToolBar->insertWidget(ui->actionRemove_Last_Shred, expandingSpace);

    QDesktopWidget * desktopWidget = QApplication::desktop();
    QRect available = desktopWidget->availableGeometry(this);

    // center horizontally, top 100px down from top
    this->move(available.left() + available.width()*0.5 - this->frameGeometry().width()/2,
               100);

    // position left edge at 0.2, bottom edge at 0.8
    m_consoleMonitor->move(available.left() + available.width()*0.2,
                           available.top() + available.height()*0.8 - m_consoleMonitor->frameGeometry().height());
    m_consoleMonitor->setAttribute(Qt::WA_QuitOnClose, false);
    m_consoleMonitor->show();

    // position right edge at 0.8, center vertically
    m_vmMonitor->move(available.left() + available.width()*0.8 - m_vmMonitor->frameGeometry().width(),
                      available.top() + available.height()*0.2);
    m_vmMonitor->setAttribute(Qt::WA_QuitOnClose, false);
    m_vmMonitor->show();

    m_preferencesWindow = new mAPreferencesWindow(NULL, ma);
    // position in center of main window
    m_preferencesWindow->move(this->pos().x() + this->frameGeometry().width()/2 - m_preferencesWindow->frameGeometry().width()/2,
                              this->pos().y() + this->frameGeometry().height()/2 - m_preferencesWindow->frameGeometry().height()/2);
    m_preferencesWindow->setAttribute(Qt::WA_QuitOnClose, false);

    newFile();
}

void mAMainWindow::setLockdown(bool _lockdown)
{
    if(_lockdown && !m_lockdown)
    {
        int ret = QMessageBox::warning(this, "", "<b>The Virtual Machine appears to be hanging.</b><br/><br/> This can be caused by a shred running in an infinite loop, or it may simply be a shred performing a finite amount of heavy processing.  If you would like to abort the current shred and unhang the virtual machine, click \"Abort.\"  To leave the current shred running, click \"Cancel.\"  If you choose to leave the current shred running, execution of on-the-fly programming commands may be delayed.<br/><br/>Abort the current shred?",
                                       "Cancel", "Abort", "", 1);
        if(ret == QDialog::Accepted)
        {
            ma->abort_current_shred();
        }
    }

    m_lockdown = _lockdown;
}

mAMainWindow::~mAMainWindow()
{
    if(vm_on)
    {
        ma->stop_vm();
    }

    ma->free_document_id(m_docid);

    // manually detach
    // each window has a pointer to the miniAudicle object
    // so we have to detach that object before deleting the miniAudicle
    for(int i = ui->tabWidget->count()-1; i >= 0; i--)
    {
        mADocumentView * view = (mADocumentView *) ui->tabWidget->widget(i);
        view->detach();
    }

    delete m_vmMonitor;
    m_vmMonitor = NULL;
    delete m_consoleMonitor;
    m_consoleMonitor = NULL;
    delete m_preferencesWindow;
    m_preferencesWindow = NULL;
    delete ui;
    ui = NULL;
    delete ma;
    ma = NULL;
}


void mAMainWindow::exit()
{
    if(shouldCloseOrQuit())
        qApp->exit(0);
}

void mAMainWindow::closeEvent(QCloseEvent * event)
{
    if(shouldCloseOrQuit())
        event->accept();
    else
        event->ignore();
}

bool mAMainWindow::shouldCloseOrQuit()
{
    list<mADocumentView *> unsavedViews;

    for(int i = 0; i < ui->tabWidget->count(); i++)
    {
        mADocumentView * view = (mADocumentView *) ui->tabWidget->widget(i);
        if(view->isDocumentModified())
            unsavedViews.push_back(view);
    }

    bool review = false;

    if(unsavedViews.size() == 1)
    {
        review = true;
    }
    else if(unsavedViews.size() > 1)
    {
        QMessageBox messageBox(this);

        messageBox.window()->setWindowFlags(Qt::Dialog | Qt::WindowTitleHint | Qt::CustomizeWindowHint);
        messageBox.window()->setWindowIcon(this->windowIcon());

        messageBox.setIcon(QMessageBox::Warning);
        messageBox.setText(QString("<b>You have %1 documents with unsaved changes. Do you want to review these changes before quitting?</b>").arg(unsavedViews.size()));
        messageBox.setInformativeText("If you don’t review your documents, all your changes will be lost.");

        messageBox.setDefaultButton(messageBox.addButton("Review Changes", QMessageBox::AcceptRole));
        messageBox.setEscapeButton(messageBox.addButton("Cancel", QMessageBox::RejectRole));
        messageBox.addButton("Discard Changes", QMessageBox::DestructiveRole);

        int ret = messageBox.exec();

        QMessageBox::ButtonRole role = messageBox.buttonRole(messageBox.clickedButton());
        if(role == QMessageBox::AcceptRole)
        {
            review = true;
        }
        else if(ret == QMessageBox::DestructiveRole)
        {
        }
        else
        {
            return false;
        }
    }

    if(review)
    {
        for(int i = ui->tabWidget->count()-1; i >= 0; i--)
        {
            if(!performClose(i))
            {
                return false;
            }
        }
    }

    return true;
}

void mAMainWindow::about()
{
    char buf[256];
    snprintf(buf, 256, MA_ABOUT, MA_VERSION, CK_VERSION, sizeof(void*)*8);
    QString body = QString("<h3>miniAudicle</h3>\n") + buf;
    body.replace(QRegExp("\n"), "<br />");
    QMessageBox::about(this, "About miniAudicle", body);
}

void mAMainWindow::newFile()
{
    mADocumentView * documentView = new mADocumentView(0, "untitled", NULL, ma);
    documentView->setTabWidget(ui->tabWidget);
    QObject::connect(m_preferencesWindow, SIGNAL(preferencesChanged()),
                     documentView, SLOT(preferencesChanged()));

    ui->tabWidget->addTab(documentView, QIcon(), "untitled");
    ui->tabWidget->setCurrentIndex(ui->tabWidget->count()-1);

    documentView->show();
}

void mAMainWindow::openFile(const QString &path)
{
    QString fileName = path;

    if(fileName.isNull())
        fileName = QFileDialog::getOpenFileName(this,
                                                tr("Open File"), "", "ChucK Scripts (*.ck)");

    if(!fileName.isEmpty())
    {
        QFile * file = new QFile(fileName);

        bool canOpen = false;
        bool readOnly = false;

        if(file->open(QFile::ReadWrite))
        {
            // close -- will be reopened as needed by document view
            file->close();

            canOpen = true;
            readOnly = false;
        }
        else if(file->open(QFile::ReadOnly))
        {
            // close -- will be reopened as needed by document view
            file->close();

            canOpen = true;
            readOnly = true;
        }

        if(canOpen)
        {
            QFileInfo fileInfo(fileName);
            mADocumentView * documentView = new mADocumentView(0, fileInfo.fileName().toStdString(), file, ma);
            documentView->setTabWidget(ui->tabWidget);
            documentView->setReadOnly(readOnly);

            QObject::connect(m_preferencesWindow, SIGNAL(preferencesChanged()),
                             documentView, SLOT(preferencesChanged()));

            ui->tabWidget->addTab(documentView, QIcon(), fileInfo.fileName());
            ui->tabWidget->setCurrentIndex(ui->tabWidget->count()-1);

            documentView->show();

            QString path = documentView->filePath();
            addRecentFile(path);
            updateRecentFilesMenu();
        }
        else
        {
            // report error
            QMessageBox::critical(this, "", QString("Unable to open file at '%1'.").arg(fileName));
        }
    }
}

void mAMainWindow::openExample()
{
    QString examplesDir;
#ifdef __PLATFORM_WIN32__
    examplesDir = QCoreApplication::applicationDirPath() + "/examples/";
//    fprintf(stderr, "examplesDir: %s\n", examplesDir.toAscii().constData());
//    fflush(stderr);
//    examplesDir = "C:/Program Files/ChucK/examples/";
#endif

    QFileDialog dialog(this, "Open Example", examplesDir, "ChucK Scripts (*.ck)");
    dialog.setFileMode(QFileDialog::ExistingFile);
    
    int result = dialog.exec();
    
    if(result == QDialog::Accepted && 
            dialog.selectedFiles().size() > 0 && 
            !dialog.selectedFiles()[0].isEmpty())
    {
        QString fileName = dialog.selectedFiles()[0];
        
        QFile * file = new QFile(fileName);
        if(file->open(QFile::ReadOnly))
        {
            // close -- will be reopened as needed by document view
            file->close();
            QFileInfo fileInfo(fileName);
            mADocumentView * documentView = new mADocumentView(0, fileInfo.fileName().toStdString(), file, ma);
            documentView->setTabWidget(ui->tabWidget);
            QObject::connect(m_preferencesWindow, SIGNAL(preferencesChanged()),
                             documentView, SLOT(preferencesChanged()));
            documentView->setReadOnly(true);

            ui->tabWidget->addTab(documentView, QIcon(), fileInfo.fileName());
            ui->tabWidget->setCurrentIndex(ui->tabWidget->count()-1);

            documentView->show();

            QString path = documentView->filePath();
            addRecentFile(path);
            updateRecentFilesMenu();
        }
        else
        {
            // report error
            QMessageBox::critical(this, "", QString("Unable to open file at '%1'.").arg(fileName));
        }
    }
}

void mAMainWindow::openRecent()
{
    QAction *action = qobject_cast<QAction *>(sender());
    if(action)
        openFile(action->data().toString());
}

void mAMainWindow::closeFile()
{
    closeFile(ui->tabWidget->currentIndex());
}

void mAMainWindow::closeFile(int i)
{
    performClose(i);
}

bool mAMainWindow::performClose(int i)
{
    mADocumentView * view = (mADocumentView *) ui->tabWidget->widget(i);

    if(view == NULL)
        return true;

    if(view->isDocumentModified())
    {
        QMessageBox msgBox;
        msgBox.setText(QString("<b>The document '%1' has been modified.</b>").arg(view->title().c_str()));
        msgBox.setInformativeText("Do you want to save your changes?");
        msgBox.setStandardButtons(QMessageBox::Save | QMessageBox::Discard | QMessageBox::Cancel);
        msgBox.setDefaultButton(QMessageBox::Save);
        msgBox.setIcon(QMessageBox::Warning);
        int ret = msgBox.exec();

        if(ret == QMessageBox::Save)
        {
            view->save();
        }
        else if(ret == QMessageBox::Cancel)
        {
            return false;
        }
    }

    ui->tabWidget->removeTab(i);
    delete view;

    return true;
}

void mAMainWindow::saveFile()
{
    mADocumentView * view = (mADocumentView *) ui->tabWidget->currentWidget();

    if(view == NULL)
        return;

    view->save();

    QString path = view->filePath();
    if(path.length())
    {
        addRecentFile(path);
        updateRecentFilesMenu();
    }
}

void mAMainWindow::saveAs()
{
    mADocumentView * view = (mADocumentView *) ui->tabWidget->currentWidget();

    if(view == NULL)
        return;

    // TODO: have saveAs() and save() return true if save was successful
    // then update recent files according to that
    view->saveAs();

    QString path = view->filePath();
    if(path.length())
    {
        addRecentFile(path);
        updateRecentFilesMenu();
    }
}

void mAMainWindow::tabSelected(int index)
{
    mADocumentView * currentView = (mADocumentView *) ui->tabWidget->currentWidget();

    ui->actionUndo->disconnect();
    ui->actionRedo->disconnect();
    ui->actionCut->disconnect();
    ui->actionCopy->disconnect();
    ui->actionPaste->disconnect();
    ui->actionSelect_All->disconnect();
    ui->actionExport_as_WAV->disconnect();

    if(currentView == NULL)
    {
        statusBar()->clearMessage();
        return;
    }

    string result = currentView->lastResult();
    if(result.size())
        statusBar()->showMessage(QString(result.c_str()));
    else
        statusBar()->clearMessage();

    connect(ui->actionUndo, SIGNAL(triggered()), currentView, SIGNAL(undo()));
    connect(ui->actionRedo, SIGNAL(triggered()), currentView, SIGNAL(redo()));
    connect(ui->actionCut, SIGNAL(triggered()), currentView, SIGNAL(cut()));
    connect(ui->actionCopy, SIGNAL(triggered()), currentView, SIGNAL(copy()));
    connect(ui->actionPaste, SIGNAL(triggered()), currentView, SIGNAL(paste()));
    connect(ui->actionSelect_All, SIGNAL(triggered()), currentView, SIGNAL(selectAll()));
    connect(ui->actionExport_as_WAV, SIGNAL(triggered()), currentView, SLOT(exportAsWav()));
}

#pragma mark

void mAMainWindow::addCurrentDocument()
{
    mADocumentView *currentDocument = ((mADocumentView *) ui->tabWidget->currentWidget());

    currentDocument->add();

    string result = currentDocument->lastResult();
    if(result.size())
        statusBar()->showMessage(QString(result.c_str()));
    else
        statusBar()->clearMessage();
}

void mAMainWindow::replaceCurrentDocument()
{
    mADocumentView *currentDocument = ((mADocumentView *) ui->tabWidget->currentWidget());

    currentDocument->replace();

    string result = currentDocument->lastResult();
    if(result.size())
        statusBar()->showMessage(QString(result.c_str()));
    else
        statusBar()->clearMessage();
}

void mAMainWindow::removeCurrentDocument()
{
    mADocumentView *currentDocument = ((mADocumentView *) ui->tabWidget->currentWidget());

    currentDocument->remove();

    string result = currentDocument->lastResult();
    if(result.size())
        statusBar()->showMessage(QString(result.c_str()));
    else
        statusBar()->clearMessage();
}

void mAMainWindow::removeLastShred()
{
    string result;
    ma->removelast(m_docid, result);
}

void mAMainWindow::removeAllShreds()
{
    string result;
    ma->removeall(m_docid, result);
}

void mAMainWindow::abortCurrentShred()
{
    ma->abort_current_shred();
}

void mAMainWindow::toggleVM()
{
    ZSettings settings;

    if(!vm_on)
    {
        ma->set_enable_audio(settings.get(mAPreferencesEnableAudio).toBool());
        ma->set_enable_network_thread(settings.get(mAPreferencesEnableNetwork).toBool());
        ma->set_adc(settings.get(mAPreferencesAudioInput).toInt());
        ma->set_dac(settings.get(mAPreferencesAudioOutput).toInt());
        ma->set_num_inputs(settings.get(mAPreferencesInputChannels).toInt());
        ma->set_num_outputs(settings.get(mAPreferencesOutputChannels).toInt());
        ma->set_sample_rate(settings.get(mAPreferencesSampleRate).toInt());
        ma->set_buffer_size(settings.get(mAPreferencesBufferSize).toInt());

        list<string> chuginDirs;
        list<string> chuginFiles;

        if(settings.get(mAPreferencesEnableChuGins).toBool())
        {
            QStringList chuginPaths = settings.get(mAPreferencesChuGinPaths).toStringList();
            for(int i = 0; i < chuginPaths.length(); i++)
            {
                QString path = chuginPaths.at(i);
                QFileInfo fileInfo(path);
                if(fileInfo.isDir() || !fileInfo.exists())
                    chuginDirs.push_back(path.toStdString());
                else
                    chuginFiles.push_back(path.toStdString());
            }
        }

        ma->set_library_paths(chuginDirs);
        ma->set_named_chugins(chuginFiles);

        if(ma->start_vm())
        {
            ui->actionStart_Virtual_Machine->setText("Stop Virtual Machine");

            m_vmMonitor->vmChangedToState(true);

#ifdef __PLATFORM_WIN32__
            // windows only: disable restarting the vm
            ui->actionStart_Virtual_Machine->setEnabled(false);
#endif

            vm_on = true;
        }
    }
    else
    {
        ma->stop_vm();

        ui->actionStart_Virtual_Machine->setText("Start Virtual Machine");

        m_vmMonitor->vmChangedToState(false);

        vm_on = false;
    }

    ui->actionAdd_Shred->setEnabled(vm_on);
    ui->actionRemove_Shred->setEnabled(vm_on);
    ui->actionReplace_Shred->setEnabled(vm_on);
    ui->actionRemove_Last_Shred->setEnabled(vm_on);
    ui->actionRemove_All_Shreds->setEnabled(vm_on);
    ui->actionAdd_All_Open_Documents->setEnabled(vm_on);
    ui->actionReplace_All_Open_Documents->setEnabled(vm_on);
    ui->actionRemove_All_Open_Documents->setEnabled(vm_on);
    ui->actionAbort_Currently_Running_Shred->setEnabled(vm_on);
}


void mAMainWindow::setLogLevel()
{
    ui->actionLogNone->setChecked(false);
    ui->actionLogCore->setChecked(false);
    ui->actionLogSystem->setChecked(false);
    ui->actionLogSevere->setChecked(false);
    ui->actionLogWarning->setChecked(false);
    ui->actionLogInfo->setChecked(false);
    ui->actionLogConfig->setChecked(false);
    ui->actionLogFine->setChecked(false);
    ui->actionLogFiner->setChecked(false);
    ui->actionLogFinest->setChecked(false);
    ui->actionLogCrazy->setChecked(false);

    QObject *sender = this->sender();
    if(sender == ui->actionLogNone)         ma->set_log_level(0);
    else if(sender == ui->actionLogCore)    ma->set_log_level(1);
    else if(sender == ui->actionLogSystem)  ma->set_log_level(2);
    else if(sender == ui->actionLogSevere)  ma->set_log_level(3);
    else if(sender == ui->actionLogWarning) ma->set_log_level(4);
    else if(sender == ui->actionLogInfo)    ma->set_log_level(5);
    else if(sender == ui->actionLogConfig)  ma->set_log_level(6);
    else if(sender == ui->actionLogFine)    ma->set_log_level(7);
    else if(sender == ui->actionLogFiner)   ma->set_log_level(8);
    else if(sender == ui->actionLogFinest)  ma->set_log_level(9);
    else if(sender == ui->actionLogCrazy)   ma->set_log_level(10);

    QAction * action = qobject_cast<QAction *>(sender);
    action->setChecked(true);

    ZSettings settings;
    settings.set("/ChucK/LogLevel", ma->get_log_level());
}


void mAMainWindow::showPreferences()
{
    if(m_preferencesWindow == NULL)
    {
        m_preferencesWindow = new mAPreferencesWindow(NULL, ma);
        m_preferencesWindow->move(this->pos().x() + this->frameGeometry().width()/2 - m_preferencesWindow->frameGeometry().width()/2,
                                  this->pos().y() + this->frameGeometry().height()/2 - m_preferencesWindow->frameGeometry().height()/2);
    }

    m_preferencesWindow->show();
    m_preferencesWindow->raise();
    m_preferencesWindow->activateWindow();
}


void mAMainWindow::showConsoleMonitor()
{
    m_consoleMonitor->show();
    m_consoleMonitor->raise();
    m_consoleMonitor->activateWindow();
}

void mAMainWindow::showVirtualMachineMonitor()
{
    m_vmMonitor->show();
    m_vmMonitor->raise();
    m_vmMonitor->activateWindow();
}

void mAMainWindow::addRecentFile(QString &path)
{
    ZSettings settings;
    QStringList recentFiles = settings.get("/GUI/RecentFiles").toStringList();

    recentFiles.removeAll(path);
    while(recentFiles.length() > MAX_RECENT_FILES-1)
        recentFiles.removeLast();
    recentFiles.prepend(path);

    settings.set("/GUI/RecentFiles", recentFiles);
}

void mAMainWindow::updateRecentFilesMenu()
{
    ui->menuRecent_Files->clear();

    ZSettings settings;

    QStringList recentFiles = settings.get("/GUI/RecentFiles").toStringList();

    for(int i = 0; i < recentFiles.length(); i++)
    {
        QString path = recentFiles.at(i);
        QAction * action = new QAction(this);
        action->setText(QString("&%1   %2")
                        .arg(i+1)
                        .arg(QFileInfo(path).fileName()));
        action->setData(path);
        connect(action, SIGNAL(triggered()), SLOT(openRecent()));

        ui->menuRecent_Files->addAction(action);
    }
}
