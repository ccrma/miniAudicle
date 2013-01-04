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

    QTextBlockFormat format = ui->plainTextEdit->textCursor().blockFormat();
    format.setBottomMargin(0);
    ui->plainTextEdit->textCursor().setBlockFormat(format);

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
