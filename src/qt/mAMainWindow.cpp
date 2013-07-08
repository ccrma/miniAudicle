
#include "mAMainWindow.h"
#include "ui_mAMainWindow.h"

#include "madocumentview.h"
#include "mAConsoleMonitor.h"
#include "mAVMMonitor.h"

#include <QMessageBox>


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

    m_consoleMonitor = new mAConsoleMonitor(this);
    m_consoleMonitor->show();
    ma->set_log_level(CK_LOG_SYSTEM);

    m_vmMonitor = new mAVMMonitor(this, ma);
    m_vmMonitor->show();

    this->move(100, 50);

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

