#include "mAMainWindow.h"
#include "ui_mAMainWindow.h"

mAMainWindow::mAMainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::mAMainWindow)
{
    ui->setupUi(this);
}

mAMainWindow::~mAMainWindow()
{
    delete ui;
}
