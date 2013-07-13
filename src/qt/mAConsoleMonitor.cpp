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

mAConsoleMonitor::mAConsoleMonitor(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::mAConsoleMonitor),
    m_outNotifier(NULL),
    m_errNotifier(NULL)
{
    ui->setupUi(this);

#ifndef __PLATFORM_WIN32__
    int fd[2];

    if( pipe( fd ) )
    {
        EM_log( CK_LOG_SEVERE, "(console monitor): pipe error, disabling console monitor" );
        return;
    }

    dup2( fd[1], STDOUT_FILENO );

    out_fd = fd[0];

    if( pipe( fd ) )
    {
        EM_log( CK_LOG_SEVERE, "(console monitor): pipe error, disabling console monitor" );
        return;
    }

    dup2( fd[1], STDERR_FILENO );

    err_fd = fd[0];

    int fd_flags = fcntl( out_fd, F_GETFL );
    if( fcntl( out_fd, F_SETFL, fd_flags | O_NONBLOCK ) )
    {
        EM_log( CK_LOG_WARNING, "(console monitor): unable to set stdout to non-blocking" );
    }

    fd_flags = fcntl( err_fd, F_GETFL );
    if( fcntl( err_fd, F_SETFL, fd_flags | O_NONBLOCK ) )
    {
        EM_log( CK_LOG_WARNING, "(console monitor): unable to set stderr to non-blocking" );
    }

    setlinebuf(stdout);

#else
    
    HANDLE hRead, hWrite;
    int fd_read, fd_write;
    //FILE * stdlib_fd;

    if( !CreatePipe( &hRead, &hWrite, NULL, 8192 ) )
    {
        EM_log( CK_LOG_SEVERE, "(console monitor): pipe error %d, disabling console monitor", GetLastError() );
        return;
    }
    
    /* WARNING: Breaks under Win64! */
    fd_read = _open_osfhandle( ( long ) hRead, _O_RDONLY | _O_TEXT );
    fd_write = _open_osfhandle( ( long ) hWrite, _O_WRONLY | _O_TEXT );

    out_fd = fd_read;

    stdlib_fd = _fdopen( fd_write, "w" );

    setvbuf( stdlib_fd, NULL, _IONBF, 0 );
    
    *stderr = *stdlib_fd;
    *stdout = *stdlib_fd;    
    
#endif

    m_outNotifier = new QSocketNotifier( out_fd, QSocketNotifier::Read );
    connect(m_outNotifier, SIGNAL(activated(int)), this, SLOT(appendFromFile(int)));
    m_outNotifier->setEnabled(true);
    m_errNotifier = new QSocketNotifier( err_fd, QSocketNotifier::Read );
    connect(m_errNotifier, SIGNAL(activated(int)), this, SLOT(appendFromFile(int)));
    m_errNotifier->setEnabled(true);
}

mAConsoleMonitor::~mAConsoleMonitor()
{
    delete m_outNotifier;
    delete m_errNotifier;
    delete ui;
}

void mAConsoleMonitor::appendFromFile(int fd)
{
#define BUF_SIZE 8192
    static char buf[BUF_SIZE];
    int len = 0;

    len = read( fd, buf, BUF_SIZE-1 );

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
