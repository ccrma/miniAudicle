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

#include <QMessageBox>
#include <QDesktopWidget>


extern const char MA_VERSION[];
extern const char MA_ABOUT[];
extern const char MA_HELP[];
extern const char CK_VERSION[];


mAMainWindow::mAMainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::mAMainWindow),
    ma(new miniAudicle)
{
    vm_on = false;
    m_docid = ma->allocate_document_id();

    ui->setupUi(this);

    ui->actionAdd_Shred->setEnabled(false);
    ui->actionRemove_Shred->setEnabled(false);
    ui->actionReplace_Shred->setEnabled(false);
    ui->actionRemove_Last_Shred->setEnabled(false);
    ui->actionRemove_All_Shreds->setEnabled(false);

    QWidget * expandingSpace = new QWidget;
    expandingSpace->setSizePolicy(QSizePolicy::Expanding, QSizePolicy::Preferred);
    ui->mainToolBar->insertWidget(ui->actionRemove_Last_Shred, expandingSpace);

    QDesktopWidget * desktopWidget = QApplication::desktop();
    QRect available = desktopWidget->availableGeometry(this);

    m_consoleMonitor = new mAConsoleMonitor(NULL);
    // position left edge at 0.2, bottom edge at 0.8
    m_consoleMonitor->move(available.left() + available.width()*0.2,
                           available.top() + available.height()*0.8 - m_consoleMonitor->frameGeometry().height());
    m_consoleMonitor->show();
    ma->set_log_level(CK_LOG_SYSTEM);

    m_vmMonitor = new mAVMMonitor(NULL, this, ma);
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
    QMessageBox::about(this, "About miniAudicle", tr("<b>miniAudicle</b>\n") + buf);
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

    if (!fileName.isEmpty()) {
        QFile * file = new QFile(fileName);
        if (file->open(QFile::ReadWrite | QFile::Text))
        {
            QFileInfo fileInfo(fileName);
            mADocumentView * documentView = new mADocumentView(0, fileInfo.fileName().toStdString(), file, ma);
            documentView->setTabWidget(ui->tabWidget);

            ui->tabWidget->addTab(documentView, QIcon(), fileInfo.fileName());
            ui->tabWidget->setCurrentIndex(ui->tabWidget->count()-1);

            documentView->show();
        }
    }
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

            ui->actionAdd_Shred->setEnabled(true);
            ui->actionRemove_Shred->setEnabled(true);
            ui->actionReplace_Shred->setEnabled(true);
            ui->actionRemove_Last_Shred->setEnabled(true);
            ui->actionRemove_All_Shreds->setEnabled(true);

            m_vmMonitor->vmChangedToState(true);

            vm_on = true;
        }
    }
    else
    {
        ma->stop_vm();

        ui->actionStart_Virtual_Machine->setText("Start Virtual Machine");

        ui->actionAdd_Shred->setEnabled(false);
        ui->actionRemove_Shred->setEnabled(false);
        ui->actionReplace_Shred->setEnabled(false);
        ui->actionRemove_Last_Shred->setEnabled(false);
        ui->actionRemove_All_Shreds->setEnabled(false);

        m_vmMonitor->vmChangedToState(false);

        vm_on = false;
    }
}

