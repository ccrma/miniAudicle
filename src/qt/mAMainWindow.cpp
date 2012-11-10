
#include "mAMainWindow.h"
#include "ui_mAMainWindow.h"

#include <QMessageBox>


mAMainWindow::mAMainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::mAMainWindow)
{
    ui->setupUi(this);

    newFile();
}

mAMainWindow::~mAMainWindow()
{
    delete ui;
}


void mAMainWindow::exit()
{
    qApp->exit(0);
}

void mAMainWindow::newFile()
{
    mADocumentView * documentView = new mADocumentView(0, "untitled");
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
            mADocumentView * documentView = new mADocumentView(0, fileInfo.fileName().toStdString(), file);
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
