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

#ifndef MAVMMONITOR_H
#define MAVMMONITOR_H

#include <QtWidgets/QMainWindow>
#include "miniAudicle.h"

namespace Ui {
class mAVMMonitor;
}

class mAMainWindow;

class mAVMMonitor : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit mAVMMonitor(QWidget *parent, mAMainWindow *mainWindow, miniAudicle * ma);
    ~mAVMMonitor();
    
    void vmChangedToState(bool on);

public slots:
    void toggleVM();
    void removeLast();
    void removeAll();

    void removeShred();

private:
    Ui::mAVMMonitor *ui;
    mAMainWindow * const m_mainWindow;

    miniAudicle * const ma;
    t_CKUINT m_docid;

    t_CKUINT vm_stall_count;
    t_CKUINT vm_max_stalls;
    int timerId;
    Chuck_VM_Status status;

    void timerEvent(QTimerEvent *event);
};

#endif // MAVMMONITOR_H
