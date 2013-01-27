#include "mAVMMonitor.h"
#include "ui_mAVMMonitor.h"

mAVMMonitor::mAVMMonitor(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::mAVMMonitor)
{
    ui->setupUi(this);
}

mAVMMonitor::~mAVMMonitor()
{
    delete ui;
}
