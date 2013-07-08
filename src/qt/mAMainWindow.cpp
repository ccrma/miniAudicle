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
#include <QSettings>


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

    m_consoleMonitor = new mAConsoleMonitor(NULL);
    m_vmMonitor = new mAVMMonitor(NULL, this, ma);
    m_preferencesWindow = NULL;

    m_docid = ma->allocate_document_id();

    ui->actionAdd_Shred->setEnabled(false);
    ui->actionRemove_Shred->setEnabled(false);
    ui->actionReplace_Shred->setEnabled(false);
    ui->actionRemove_Last_Shred->setEnabled(false);
    ui->actionRemove_All_Shreds->setEnabled(false);

    updateRecentFilesMenu();
    
    QSettings settings;
    ma->set_log_level(settings.value("/ChucK/LogLevel", (int) 2).toInt());
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

    // position left edge at 0.2, bottom edge at 0.8
    m_consoleMonitor->move(available.left() + available.width()*0.2,
                           available.top() + available.height()*0.8 - m_consoleMonitor->frameGeometry().height());
    m_consoleMonitor->show();

    // position right edge at 0.8, center vertically
    m_vmMonitor->move(available.left() + available.width()*0.8 - m_vmMonitor->frameGeometry().width(),
                      available.top() + available.height()*0.2);
    m_vmMonitor->show();

    // center horizontally, top 100px down from top
    this->move(available.left() + available.width()*0.5 - this->frameGeometry().width()/2,
               100);

    newFile();
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
    delete ui;
    ui = NULL;
    delete ma;
    ma = NULL;
}


void mAMainWindow::exit()
{
    qApp->exit(0);
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

    ui->tabWidget->addTab(documentView, QIcon(), "untitled");
    ui->tabWidget->setCurrentIndex(ui->tabWidget->count()-1);

    documentView->show();
}

void mAMainWindow::openFile(const QString &path)
{
    QString fileName = path;

    if (fileName.isNull())
        fileName = QFileDialog::getOpenFileName(this,
            tr("Open File"), "", "ChucK Scripts (*.ck)");

    if (!fileName.isEmpty())
    {
        QFile * file = new QFile(fileName);
        if (file->open(QFile::ReadWrite | QFile::Text))
        {
            QFileInfo fileInfo(fileName);
            mADocumentView * documentView = new mADocumentView(0, fileInfo.fileName().toStdString(), file, ma);
            documentView->setTabWidget(ui->tabWidget);

            ui->tabWidget->addTab(documentView, QIcon(), fileInfo.fileName());
            ui->tabWidget->setCurrentIndex(ui->tabWidget->count()-1);

            documentView->show();
            
            QString path = documentView->filePath();
            addRecentFile(path);
            updateRecentFilesMenu();            
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
    mADocumentView * view = (mADocumentView *) ui->tabWidget->widget(i);

    if(view == NULL)
        return;

    if(view->isDocumentModified())
    {
        QMessageBox msgBox;
        msgBox.setText("The document has been modified.");
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
            return;
        }
    }

    ui->tabWidget->removeTab(i);
    delete view;
}

void mAMainWindow::saveFile()
{
    mADocumentView * view = (mADocumentView *) ui->tabWidget->currentWidget();

    if(view == NULL)
        return;

    view->save();

    QString path = view->filePath();
    addRecentFile(path);
    updateRecentFilesMenu();
}

#pragma mark

void mAMainWindow::addCurrentDocument()
{
    ((mADocumentView *) ui->tabWidget->currentWidget())->add();
}

void mAMainWindow::replaceCurrentDocument()
{
    ((mADocumentView *) ui->tabWidget->currentWidget())->replace();
}

void mAMainWindow::removeCurrentDocument()
{
    ((mADocumentView *) ui->tabWidget->currentWidget())->remove();
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

void mAMainWindow::toggleVM()
{
    if(!vm_on)
    {
        if(ma->start_vm())
        {
            ui->actionStart_Virtual_Machine->setText("Stop Virtual Machine");

            m_vmMonitor->vmChangedToState(true);

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
    
    QSettings settings;
    settings.setValue("/ChucK/LogLevel", ma->get_log_level());
}


void mAMainWindow::showPreferences()
{
    if(m_preferencesWindow == NULL)
    {
        m_preferencesWindow = new mAPreferencesWindow();
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
    QSettings settings;
    QList<QString> recentFiles;
    int len = settings.beginReadArray("RecentFiles");
    int i = 0;
    for(i = 0; i < len; i++)
        recentFiles.append(settings.value("path").toString());
    settings.endArray();
    
    while(recentFiles.length() > MAX_RECENT_FILES-1)
        recentFiles.removeLast();
    recentFiles.prepend(path);
    
    settings.beginWriteArray("RecentFiles", recentFiles.length());
    len = recentFiles.length();
    for(i = 0; i < len; i++)
        settings.setValue("path", recentFiles.at(i));
    settings.endArray();
}

void mAMainWindow::updateRecentFilesMenu()
{
    ui->menuRecent_Files->clear();
    
    QSettings settings;
    int len = settings.beginReadArray("RecentFiles");
    int i = 0;
    for(i = 0; i < len; i++)
    {
        QString path = settings.value("path").toString();
        QAction * action = new QAction(this);
        action->setText(QString("&%1 %2")
                        .arg(i+1)
                        .arg(QFileInfo(path).fileName()));
        action->setData(path);
        connect(action, SIGNAL(triggered()), SLOT(openRecent()));
        
        ui->menuRecent_Files->addAction(action);
    }
    settings.endArray();
}
