#include "mAVMMonitor.h"
#include "ui_mAVMMonitor.h"
#include "mAMainWindow.h"

const float VMMONITOR_REFRESH_RATE = 20; // Hz

mAVMMonitor::mAVMMonitor(QWidget *parent, miniAudicle * _ma) :
    QMainWindow(parent),
    ui(new Ui::mAVMMonitor),
    ma(_ma)
{
    ui->setupUi(this);

    timerId = -1;
    vm_stall_count = 0;

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
}

mAVMMonitor::~mAVMMonitor()
{
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
}

void mAVMMonitor::toggleVM()
{
    mAMainWindow * mainWindow = (mAMainWindow *) this->parent();
    mainWindow->toggleVM();
}

void mAVMMonitor::removeAll()
{
    mAMainWindow * mainWindow = (mAMainWindow *) this->parent();
}

void mAVMMonitor::removeLast()
{
    mAMainWindow * mainWindow = (mAMainWindow *) this->parent();
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

//        if( vm_stall_count >= vm_max_stalls && !wxGetApp().IsInLockdown() )
//        {
//            wxGetApp().SetLockdown( TRUE );
//        }
    }

    else
    {
//        if( wxGetApp().IsInLockdown() )
//            wxGetApp().SetLockdown( FALSE );
        vm_stall_count = 0;
    }

    last_now_system = status.now_system;

    ui->tableWidget->setRowCount(num_shreds);

    now = ( time_t ) ( status.now_system / status.srate );
//    if( now != last_now )
    {
        t_CKUINT samps = fmod( status.now_system, status.srate );
        ui->runningTimeLabel->setText(QString("%1:%2.%3")
                                      .arg((uint)(now/60))
                                      .arg((uint)(now%60), 2, 10, QLatin1Char('0'))
                                      .arg((uint)samps, 5, 10, QLatin1Char('0')));
        last_now = now;
    }

    if( num_shreds != last_num_shreds )
    {
        ui->shredCountLabel->setText(QString("%1").arg(num_shreds));
        last_num_shreds = num_shreds;
    }

    for( int i = 0; i < num_shreds; i++ )
    {
        ui->tableWidget->setRowHeight(i, 18);

        QString shred = QString("%1").arg(status.list[i]->xid);
        if(ui->tableWidget->item(i, 0) == NULL)
        {
            QTableWidgetItem * item = new QTableWidgetItem(shred);
            item->font().setPointSize(8);
            item->setFlags(Qt::ItemIsSelectable);
            ui->tableWidget->setItem(i, 0, item);
        }
        else
            ui->tableWidget->item(i, 0)->setText(shred);

        QString name = QString("%1").arg(status.list[i]->name.c_str());
        if(ui->tableWidget->item(i, 1) == NULL)
        {
            QTableWidgetItem * item = new QTableWidgetItem(name);
            item->font().setPointSize(8);
            item->setFlags(Qt::ItemIsSelectable);
            ui->tableWidget->setItem(i, 1, item);
        }
        else
            ui->tableWidget->item(i, 1)->setText(name);

        age = ( time_t ) ( ( status.now_system - status.list[i]->start ) / status.srate );
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

//        grid->SetCellValue( i, 3, _T( "-" ) );
    }

//    grid->ClearSelection();
//    grid->Refresh();
}

