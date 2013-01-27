#ifndef MAVMMONITOR_H
#define MAVMMONITOR_H

#include <QMainWindow>

namespace Ui {
class mAVMMonitor;
}

class mAVMMonitor : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit mAVMMonitor(QWidget *parent = 0);
    ~mAVMMonitor();
    
private:
    Ui::mAVMMonitor *ui;
};

#endif // MAVMMONITOR_H
