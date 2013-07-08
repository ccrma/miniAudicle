#include "mAPreferencesWindow.h"
#include "ui_mAPreferencesWindow.h"

mAPreferencesWindow::mAPreferencesWindow(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::mAPreferencesWindow)
{
    ui->setupUi(this);
    
    ui->tabWidget->setCurrentIndex(0);
}

mAPreferencesWindow::~mAPreferencesWindow()
{
    delete ui;
}

void mAPreferencesWindow::ok()
{
    
}

void mAPreferencesWindow::cancel()
{
    
}

void mAPreferencesWindow::restoreDefaults()
{
    
}
