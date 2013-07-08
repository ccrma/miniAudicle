#include "mAPreferencesWindow.h"
#include "ui_mAPreferencesWindow.h"

mAPreferencesWindow::mAPreferencesWindow(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::mAPreferencesWindow)
{
    ui->setupUi(this);
    
    //setWindowFlags(windowFlags() & ~(Qt::WindowCloseButtonHint));
    setWindowFlags(Qt::Window | Qt::WindowTitleHint | Qt::CustomizeWindowHint);
    
    ui->tabWidget->setCurrentIndex(0);
}

mAPreferencesWindow::~mAPreferencesWindow()
{
    delete ui;
}

void mAPreferencesWindow::ok()
{
    close();
}

void mAPreferencesWindow::cancel()
{
    close();
}

void mAPreferencesWindow::restoreDefaults()
{
    
}
