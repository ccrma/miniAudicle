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

#ifndef MACONSOLEMONITOR_H
#define MACONSOLEMONITOR_H

#include <QtWidgets/QMainWindow>
#include <QSocketNotifier>
#include <QThread>

#ifdef __PLATFORM_WIN32__
#include <windows.h>
#endif

namespace Ui {
class mAConsoleMonitor;
}

class mAConsoleMonitorThread;

class mAConsoleMonitor : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit mAConsoleMonitor(QWidget *parent = 0);
    ~mAConsoleMonitor();
    
public slots:
    void appendFromFile(int fd);
    void dataAvailable();

private:
    Ui::mAConsoleMonitor *ui;

#ifdef __PLATFORM_WIN32__
    HANDLE hRead, hWrite;
#endif
    
    int read_fd;
    
    QSocketNotifier * m_notifier;
    
    friend class mAConsoleMonitorThread;
};


class mAConsoleMonitorThread : public QThread
{
    Q_OBJECT
    
public:
    mAConsoleMonitorThread(mAConsoleMonitor * _consoleMonitor, QObject *parent = 0) :
        QThread(parent),
        m_consoleMonitor(_consoleMonitor)
    {
    }
    
signals:
    void dataAvailable();
    
protected:
    mAConsoleMonitor * m_consoleMonitor;
    
    virtual void run();
};




#endif // MACONSOLEMONITOR_H
