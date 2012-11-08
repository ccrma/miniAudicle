
#include "mAMainWindow.h"
#include "ui_mAMainWindow.h"



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

    documents.push_back(documentView);

    ui->tabWidget->addTab(documentView, QIcon(), "untitled");
    ui->tabWidget->setCurrentIndex(ui->tabWidget->count()-1);

    documentView->show();
}

void mAMainWindow::openFile()
{

}

void mAMainWindow::closeFile()
{

}

void mAMainWindow::closeFile(int i)
{

}
