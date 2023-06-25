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

#include "mAVMMonitor.h"
#include "ui_mAVMMonitor.h"
#include "mAMainWindow.h"

#include <math.h>

using namespace std;

const float VMMONITOR_STALL_TIMEOUT = 2; // secondss
const float VMMONITOR_REFRESH_RATE = 20; // Hz

mAVMMonitor::mAVMMonitor(QWidget *parent, mAMainWindow *mainWindow, miniAudicle * _ma) :
    QMainWindow(parent),
    ui(new Ui::mAVMMonitor),
    m_mainWindow(mainWindow),
    ma(_ma)
{
    ui->setupUi(this);

    timerId = -1;
    vm_stall_count = 0;
    vm_max_stalls = VMMONITOR_STALL_TIMEOUT*VMMONITOR_REFRESH_RATE;

    m_docid = ma->allocate_document_id();

    ui->shredCountLabel->setText("");
    ui->runningTimeLabel->setText("");
    ui->removeLastButton->setEnabled(false);
    ui->removeAllButton->setEnabled(false);

    ui->tableWidget->setColumnCount(4);
    ui->tableWidget->setShowGrid(true);
    ui->tableWidget->verticalHeader()->setHidden(true);
    
    ui->tableWidget->setHorizontalHeaderItem(0, new QTableWidgetItem("shred"));
    ui->tableWidget->setHorizontalHeaderItem(1, new QTableWidgetItem("name"));
    ui->tableWidget->setHorizontalHeaderItem(2, new QTableWidgetItem("time"));
    ui->tableWidget->setHorizontalHeaderItem(3, new QTableWidgetItem("-"));
    
    ui->tableWidget->setColumnWidth(0, 48);
    ui->tableWidget->setColumnWidth(1, 156);
    ui->tableWidget->setColumnWidth(2, 48);
    ui->tableWidget->setColumnWidth(3, 24);
    
    ui->tableWidget->horizontalHeader()->setSectionResizeMode(1, QHeaderView::Stretch);
}

mAVMMonitor::~mAVMMonitor()
{
    ma->free_document_id(m_docid);

    delete ui;
}

void mAVMMonitor::vmChangedToState(bool vmOn)
{
    if(vmOn)
    {
        ui->toggleVMButton->setText("Stop Virtual Machine");

        timerId = startTimer((int)(1000.0/VMMONITOR_REFRESH_RATE));
    }
    else
    {
        ui->toggleVMButton->setText("Start Virtual Machine");

        if(timerId != -1)
        {
            killTimer(timerId);
            timerId = -1;
        }

        ui->runningTimeLabel->setText("");
        ui->shredCountLabel->setText("");

        ui->tableWidget->setRowCount(0);
    }

    ui->removeLastButton->setEnabled(vmOn);
    ui->removeAllButton->setEnabled(vmOn);
}

void mAVMMonitor::toggleVM()
{
    m_mainWindow->toggleVM();
}

void mAVMMonitor::removeAll()
{
    string result;
    ma->clearvm(m_docid, result);
}

void mAVMMonitor::removeLast()
{
    string result;
    ma->removelast(m_docid, result);
}

void mAVMMonitor::timerEvent(QTimerEvent *event)
{
    static time_t last_now = 0 - 1;
    static t_CKTIME last_now_system = 0;
    static int last_num_shreds = -1;

//    fprintf(stderr, "timer\n");

    ma->status( &status );
    QString temp;
    time_t age, now;
    int num_rows = ui->tableWidget->rowCount();
    int num_shreds = status.list.size();

    if( /*status.now_system > status.srate &&*/( status.now_system - last_now_system ) < 0.5 )
    {
        vm_stall_count++;

        if( vm_stall_count >= vm_max_stalls && !m_mainWindow->lockdown() )
        {
            m_mainWindow->setLockdown(true);
        }
    }

    else
    {
//        if( wxGetApp().IsInLockdown() )
//            wxGetApp().SetLockdown( FALSE );
        if(m_mainWindow->lockdown())
            m_mainWindow->setLockdown(false);
        vm_stall_count = 0;
    }

    last_now_system = status.now_system;

    ui->tableWidget->setRowCount(num_shreds);

    // chuck time display
    now = (time_t)(status.now_system/status.srate);
    t_CKUINT samps = fmod(status.now_system, status.srate);
    // under one hour
    if( now < 3600 )
    {
        // minutes:seconds.samples
        ui->runningTimeLabel->setText(QString("%1:%2.%3")
                                      .arg((uint)(now/60))
                                      .arg((uint)(now%60), 2, 10, QLatin1Char('0'))
                                      .arg((uint)samps, 5, 10, QLatin1Char('0')));
    }
    else // one hour and beyond
    {
        // hours:minutes:seconds.samples
        ui->runningTimeLabel->setText(QString("%1:%2:%3.%4")
                                      .arg((uint)(now/3600))
                                      .arg((uint)((now%3600)/60), 2, 10, QLatin1Char('0'))
                                      .arg((uint)(now%60), 2, 10, QLatin1Char('0'))
                                      .arg((uint)samps, 5, 10, QLatin1Char('0')));
    }
    // update
    last_now = now;

    // if( num_shreds != last_num_shreds )
    {
        ui->shredCountLabel->setText(QString("%1").arg(num_shreds));
        last_num_shreds = num_shreds;
    }

    for( int i = 0; i < num_shreds; i++ )
    {
        Chuck_VM_Shred_Status * shred = status.list[i];

        ui->tableWidget->setRowHeight(i, 18);

        // set shred id column
        QString shredId = QString("%1").arg(shred->xid);
        if(ui->tableWidget->item(i, 0) == NULL)
        {
            QTableWidgetItem * item = new QTableWidgetItem(shredId);
            item->font().setPointSize(8);
            item->setFlags(Qt::ItemIsSelectable);
            ui->tableWidget->setItem(i, 0, item);
        }
        else
            ui->tableWidget->item(i, 0)->setText(shredId);

        // set shred name column
        QString name = QString("%1").arg(shred->name.c_str());
        if(ui->tableWidget->item(i, 1) == NULL)
        {
            QTableWidgetItem * item = new QTableWidgetItem(name);
            item->font().setPointSize(8);
            item->setFlags(Qt::ItemIsSelectable);
            ui->tableWidget->setItem(i, 1, item);
        }
        else
            ui->tableWidget->item(i, 1)->setText(name);

        // set shred time column
        age = ( time_t ) ( ( status.now_system - shred->start ) / status.srate );
        QString time = QString("%1:%2")
                .arg((uint)(age/60))
                .arg((uint)(age%60), 2, 10, QLatin1Char('0'));
        if(ui->tableWidget->item(i, 2) == NULL)
        {
            QTableWidgetItem * item = new QTableWidgetItem(time);
            item->font().setPointSize(8);
            item->setFlags(Qt::ItemIsSelectable);
            ui->tableWidget->setItem(i, 2, item);
        }
        else
            ui->tableWidget->item(i, 2)->setText(time);

        // set remove button
        if(ui->tableWidget->cellWidget(i, 3) == NULL)
        {
            QPushButton * button = new QPushButton(ui->tableWidget);
            button->setText("-");
            button->resize(20, 16);
            button->setProperty("shred_id", QVariant((int)shred->xid));
            connect(button, SIGNAL(clicked()), SLOT(removeShred()));
            ui->tableWidget->setCellWidget(i, 3, button);
        }
        else
            ui->tableWidget->cellWidget(i, 3)->setProperty("shred_id", QVariant((int)shred->xid));
    }
}

void mAVMMonitor::removeShred()
{
    // signalled from shred table button
    t_CKINT shred_id = this->sender()->property("shred_id").toInt();
    string result;
    ma->remove_shred(m_docid, shred_id, result);
}

