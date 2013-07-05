#ifndef MAVMMONITOR_H
#define MAVMMONITOR_H

#include <QMainWindow>
#include "miniAudicle.h"

namespace Ui {
class mAVMMonitor;
}

class mAVMMonitor : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit mAVMMonitor(QWidget *parent, miniAudicle * ma);
    ~mAVMMonitor();
    
    void vmChangedToState(bool on);

public slots:
    void toggleVM();
    void removeLast();
    void removeAll();

private:
    Ui::mAVMMonitor *ui;

    miniAudicle * ma;
    t_CKUINT m_docid;

    t_CKUINT vm_stall_count;
    int timerId;
    Chuck_VM_Status status;

    void timerEvent(QTimerEvent *event);
};

#endif // MAVMMONITOR_H
