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

#include "mAConsoleMonitor.h"
#include "ui_mAConsoleMonitor.h"

#include <QScrollBar>

#include "chuck_def.h"
#include "chuck_errmsg.h"

#ifndef __PLATFORM_WIN32__
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#else
#include <windows.h>
#include <io.h>
#include <fcntl.h>
#include <stdio.h>
#endif

#define DISABLE_CONSOLE_MONITOR 0

#ifndef STDERR_FILENO
#define STDERR_FILENO 2
#endif
#ifndef STDOUT_FILENO
#define STDOUT_FILENO 1
#endif

        
mAConsoleMonitor::mAConsoleMonitor(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::mAConsoleMonitor),
    m_notifier(NULL)
{
    ui->setupUi(this);
    read_fd = 0;
#if !DISABLE_CONSOLE_MONITOR
#ifndef __PLATFORM_WIN32__
    int fd[2];

    if( pipe( fd ) )
    {
        EM_log( CK_LOG_SEVERE, "(console monitor): pipe error, disabling console monitor" );
        return;
    }

    dup2( fd[1], STDOUT_FILENO );
    dup2( fd[1], STDERR_FILENO );

    read_fd = fd[0];

    int fd_flags = fcntl( read_fd, F_GETFL );
    if( fcntl( read_fd, F_SETFL, fd_flags | O_NONBLOCK ) )
    {
        EM_log( CK_LOG_WARNING, "(console monitor): unable to set stdout to non-blocking" );
    }

    setlinebuf(stdout);
    
    m_notifier = new QSocketNotifier( read_fd, QSocketNotifier::Read );
    connect(m_notifier, SIGNAL(activated(int)), this, SLOT(appendFromFile(int)));
    m_notifier->setEnabled(true);
    
#else
    
    int fd_read, fd_write;

    if( !CreatePipe( &hRead, &hWrite, NULL, 8192 ) )
    {
        EM_log( CK_LOG_SEVERE, "(console monitor): pipe error %d, disabling console monitor", GetLastError() );
        return;
    }
        
    /* WARNING: Breaks under Win64! */
    fd_read = _open_osfhandle( ( long ) hRead, _O_RDONLY | _O_TEXT );
    fd_write = _open_osfhandle( ( long ) hWrite, _O_WRONLY | _O_TEXT );

    _dup2(fd_write, STDERR_FILENO);
    _dup2(fd_write, STDOUT_FILENO);
    read_fd = fd_read;

    FILE * cfd_write_err = _fdopen(fd_write, "w");
    FILE * cfd_write_out = _fdopen(fd_write, "w");

    *stderr = *cfd_write_err;
    *stdout = *cfd_write_out;

    mAConsoleMonitorThread * thread = new mAConsoleMonitorThread(this);
    QObject::connect(thread, SIGNAL(dataAvailable()), 
                     this, SLOT(dataAvailable()), Qt::BlockingQueuedConnection);
    thread->start();
    
#endif
#endif
}

mAConsoleMonitor::~mAConsoleMonitor()
{
    if(m_notifier) delete m_notifier;
    delete ui;
}

void mAConsoleMonitor::appendFromFile(int fd)
{
#define BUF_SIZE 8192
    static char buf[BUF_SIZE];
    int len = 0;

#ifdef __PLATFORM_WIN32__
    len = _read( fd, buf, BUF_SIZE-1 );
#else
    len = read( fd, buf, BUF_SIZE-1 );
#endif

    if(len > 0)
    {
        buf[len] = '\0';
        QScrollBar * verticalScroll = ui->plainTextEdit->verticalScrollBar();
        bool scroll = verticalScroll->sliderPosition() == verticalScroll->maximum();
        QTextCursor cursor(ui->plainTextEdit->document());
        int count = ui->plainTextEdit->document()->characterCount();
        if(count > 0)
            cursor.setPosition(count-1);
        else
            cursor.setPosition(0);
        cursor.insertText(QString(buf));

        if(scroll)
            verticalScroll->setSliderPosition(verticalScroll->maximum());
    }
}

void mAConsoleMonitor::dataAvailable()
{
    appendFromFile(read_fd);
}

void mAConsoleMonitorThread::run()
{
#ifdef __PLATFORM_WIN32__
    char one;
    DWORD read;

    while(true)
    {
        PeekNamedPipe(m_consoleMonitor->hRead, &one, 1, &read, NULL, NULL);
        if(read)
            dataAvailable();
        
        QThread::msleep(20);
    }
#endif
}

