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

#include "miniAudicle.h"
#include "chuck.h"
#include "chuck_errmsg.h"

#include <QtWidgets/QScrollBar>
#include <QMenu>
#include <QTextEdit>
#include <QPlainTextEdit>

#include <fcntl.h>
#include <stdio.h>

#ifndef __PLATFORM_WINDOWS__
#include <unistd.h>
#else
#include <windows.h>
#include <io.h>
#endif


#define DISABLE_CONSOLE_MONITOR 0

#ifndef STDERR_FILENO
#define STDERR_FILENO 2
#endif
#ifndef STDOUT_FILENO
#define STDOUT_FILENO 1
#endif

// our console monitor
static mAConsoleMonitor * g_console_monitor = NULL;


// redirect
void ck_err_out_callback( const char * str )
{
    if( g_console_monitor )
    {
        g_console_monitor->ckErrOutCallback( str );
    }
}


//-----------------------------------------------------------------------------
// name: mAConsoleMonitor()
// desc: constructor
//-----------------------------------------------------------------------------
mAConsoleMonitor::mAConsoleMonitor(QWidget *parent, miniAudicle * ma) :
    QMainWindow(parent),
    ui(new Ui::mAConsoleMonitor),
    ma_ref(ma), // 1.5.0.6 (ge) added
    m_notifier(NULL),
    m_esc2text(new AnsiEscapeCodeHandler) // 1.5.0.6 (ge) added
{
    ui->setupUi(this);
    read_fd = 0;
#if !DISABLE_CONSOLE_MONITOR
#ifndef __PLATFORM_WINDOWS__
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

    // set stream buffering: unbuffered, line-buffered (this case), or fully buffered
    setlinebuf( stdout );

    // set up reader
    m_notifier = new QSocketNotifier( read_fd, QSocketNotifier::Read );
    connect(m_notifier, SIGNAL(activated(int)), this, SLOT(appendFromFile(int)));
    m_notifier->setEnabled(true);
    
#else

    if( !CreatePipe( &hRead, &hWrite, NULL, 8192*4 ) )
    {
        EM_log( CK_LOG_SEVERE, "(console monitor): pipe error %d, disabling console monitor", GetLastError() );
        return;
    }
        
    read_fd = _open_osfhandle( ( intptr_t ) hRead, _O_RDONLY | _O_TEXT );
    write_fd = _open_osfhandle( ( intptr_t ) hWrite, _O_WRONLY | _O_TEXT );

    g_console_monitor = this;

    // redirect chuck-specific stderr output
    ma->set_ck_console_callback( ck_err_out_callback );

    mAConsoleMonitorThread * thread = new mAConsoleMonitorThread(this);
    QObject::connect(thread, SIGNAL(dataAvailable()),
                     this, SLOT(dataAvailable()), Qt::BlockingQueuedConnection);
    thread->start();
    
#endif // __PLATFORM_WINDOWS__

    // 1.5.0.7 (ge) seems to be a robust way to always move scroll bar to bottom
    // QObject::connect( ui->plainTextEdit->verticalScrollBar(), SIGNAL(rangeChanged(int,int)), this, SLOT(moveScrollBarToBottom(int,int)));

#endif // !DISABLE_CONSOLE_MONITOR
}

mAConsoleMonitor::~mAConsoleMonitor()
{
    if(m_notifier) delete m_notifier;
    delete ui;
}


//-----------------------------------------------------------------------------
// name: moveScrollBarToBottom() | 1.5.0.7 (ge) added
// desc: move scroll bar to bottom
//-----------------------------------------------------------------------------
void mAConsoleMonitor::moveScrollBarToBottom( int min, int max )
{
    Q_UNUSED(min);
    QScrollBar * scrollbar = ui->plainTextEdit->verticalScrollBar();
    scrollbar->setValue( max );
}


//-----------------------------------------------------------------------------
// name: resizeEvent() | 1.5.0.6 (ge) added
// desc: customize handling of window resize
//-----------------------------------------------------------------------------
void mAConsoleMonitor::resizeEvent( QResizeEvent* event )
{
    // call parent
    QMainWindow::resizeEvent(event);

    // handle
    handleResize();
}


//-----------------------------------------------------------------------------
// name: handleResize() | 1.5.0.6 (ge) added
// desc: handle console resize
//-----------------------------------------------------------------------------
void mAConsoleMonitor::handleResize()
{
    // get console width
    int width = ui->plainTextEdit->size().width();
    // get character columns for current width
    width = (int)(width/(double)ui->plainTextEdit->fontMetrics().averageCharWidth() + .5);
    // pad
    width -= 4;
    // tell miniAudicle about number of characters
    ma_ref->set_console_column_width_hint( width );
}


//-----------------------------------------------------------------------------
// name: formatAndOutput()
// desc: format str and output to console
//       1.5.0.6 (ge) add ansi escape code / color TTY processing
//-----------------------------------------------------------------------------
void mAConsoleMonitor::formatAndOutput( const char * str )
{
    // process text for ANSI escape codes; format text
    QList<FormattedText> list = m_esc2text->parseText( FormattedText(QString(str)) );
    // console scroll bar
    QScrollBar * verticalScroll = ui->plainTextEdit->verticalScrollBar();
    // whether to auto-scroll
    bool autoScroll = verticalScroll->sliderPosition() == verticalScroll->maximum();

    // handle resize
    handleResize();

    // get cursor
    QTextCursor cursor(ui->plainTextEdit->document());
    // get character count
    int count = ui->plainTextEdit->document()->characterCount();
    // position cursor to the end
    if(count > 0) cursor.setPosition(count-1);
    else cursor.setPosition(0);

    // loop over formatted text list
    for( int i = 0; i < list.count(); i++ )
    {
        // insert text
        cursor.insertText( list[i].text, list[i].format );
    }

    // check
    if( autoScroll )
    {
        // part of scroll to end
        ui->plainTextEdit->ensureCursorVisible();
        // scroll to the end
        verticalScroll->setSliderPosition(verticalScroll->maximum());
    }
}


//-----------------------------------------------------------------------------
// name: ckErrOutCallback()
// desc: redirect handler for chuck err stream
//-----------------------------------------------------------------------------
void mAConsoleMonitor::ckErrOutCallback( const char * str )
{
    // write to pipe
    write( write_fd, str, strlen(str) );
}


//-----------------------------------------------------------------------------
// name: appendFromFile()
// desc: append contents of file
//-----------------------------------------------------------------------------
void mAConsoleMonitor::appendFromFile(int fd)
{
#define BUF_SIZE 8192
    static char buf[BUF_SIZE];
    int len = 0;

#ifdef __PLATFORM_WINDOWS__
    len = _read( fd, buf, BUF_SIZE-1 );
#else
    len = read( fd, buf, BUF_SIZE-1 );
#endif

    if(len > 0)
    {
        // NULL terminate the string
        buf[len] = '\0';

        // format and output to console | 1.5.0.6 (ge) added
        formatAndOutput( buf );
    }
}


void mAConsoleMonitor::dataAvailable()
{
    appendFromFile(read_fd);
}


void mAConsoleMonitorThread::run()
{
#ifdef __PLATFORM_WINDOWS__
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


//-----------------------------------------------------------------------------
// name: mAPlainTextEdit()
// desc: constructor
//-----------------------------------------------------------------------------
mAPlainTextEdit::mAPlainTextEdit( QWidget * parent )
    : QPlainTextEdit(parent)
{ }

//-----------------------------------------------------------------------------
// name: ~mAPlainTextEdit()
// desc: destructor
//-----------------------------------------------------------------------------
mAPlainTextEdit::~mAPlainTextEdit()
{ }

//-----------------------------------------------------------------------------
// name: contextMenuEvent()
// desc: override QPlainTextEdit context menu event to customize it
//-----------------------------------------------------------------------------
void mAPlainTextEdit::contextMenuEvent( QContextMenuEvent * event )
{
    // first get standard context menu
    QMenu * menu = createStandardContextMenu();
    // add action and connect to slot
    menu->addAction( tr("Clear"), this, SLOT(clear()) );
    // executes the menu
    menu->exec( event->globalPos() );
    // clean up
    delete menu;
}




//-----------------------------------------------------------------------------
// in search of a VT100 color printing:
// adapted from AnsiEscapeCodeHandler
//
// Copyright (C) 2016 Petar Perisin <petar.perisin@gmail.com>
// LicenseRef-Qt-Commercial OR GPL-3.0-only WITH Qt-GPL-exception-1.0
//
// https://forum.qt.io/topic/96638/qplaintextedit-vt100-espace-sequence-support
// https://code.qt.io/cgit/qt-creator/qt-creator.git/tree/src/libs/utils/ansiescapecodehandler.h
// https://code.qt.io/cgit/qt-creator/qt-creator.git/tree/src/libs/utils/ansiescapecodehandler.cpp
//-----------------------------------------------------------------------------
/*!
    \class Utils::AnsiEscapeCodeHandler
    \inmodule QtCreator

    \brief The AnsiEscapeCodeHandler class parses text and extracts ANSI escape codes from it.

    In order to preserve color information across text segments, an instance of this class
    must be stored for the lifetime of a stream.
    Also, one instance of this class should not handle multiple streams (at least not
    at the same time).

    Its main function is parseText(), which accepts text and default QTextCharFormat.
    This function is designed to parse text and split colored text to smaller strings,
    with their appropriate formatting information set inside QTextCharFormat.

    Usage:
    \list
    \li Create new instance of AnsiEscapeCodeHandler for a stream.
    \li To add new text, call parseText() with the text and a default QTextCharFormat.
        The result of this function is a list of strings with formats set in appropriate
        QTextCharFormat.
    \endlist
*/

static QColor ansiColor(uint code)
{
//    QTC_ASSERT(code < 8, return QColor());

    const int red   = code & 1 ? 170 : 0;
    const int green = code & 2 ? 170 : 0;
    const int blue  = code & 4 ? 170 : 0;
    return QColor(red, green, blue);
}

QList<FormattedText> AnsiEscapeCodeHandler::parseText(const FormattedText &input)
{
    enum AnsiEscapeCodes {
        ResetFormat            =  0,
        BoldText               =  1,
        TextColorStart         = 30,
        TextColorEnd           = 37,
        RgbTextColor           = 38,
        DefaultTextColor       = 39,
        BackgroundColorStart   = 40,
        BackgroundColorEnd     = 47,
        RgbBackgroundColor     = 48,
        DefaultBackgroundColor = 49
    };

    const QString escape        = "\033[";
    const QChar semicolon       = ';';
    const QChar colorTerminator = 'm';
    const QChar eraseToEol      = 'K';

    QList<FormattedText> outputData;
    QTextCharFormat charFormat = m_previousFormatClosed ? input.format : m_previousFormat;
    QString strippedText;
    if (m_pendingText.isEmpty()) {
        strippedText = input.text;
    } else {
        strippedText = m_pendingText.append(input.text);
        m_pendingText.clear();
    }

    while (!strippedText.isEmpty()) {
//        QTC_ASSERT(m_pendingText.isEmpty(), break);
        if (m_waitingForTerminator) {
            // We ignore all escape codes taking string arguments.
            QString terminator = "\x1b\\";
            int terminatorPos = strippedText.indexOf(terminator);
            if (terminatorPos == -1 && !m_alternateTerminator.isEmpty()) {
                terminator = m_alternateTerminator;
                terminatorPos = strippedText.indexOf(terminator);
            }
            if (terminatorPos == -1) {
                m_pendingText = strippedText;
                break;
            }
            m_waitingForTerminator = false;
            m_alternateTerminator.clear();
            strippedText.remove(0, terminatorPos + terminator.length());
            if (strippedText.isEmpty())
                break;
        }
        const int escapePos = strippedText.indexOf(escape.at(0));
        if (escapePos < 0) {
            outputData << FormattedText(strippedText, charFormat);
            break;
        } else if (escapePos != 0) {
            outputData << FormattedText(strippedText.left(escapePos), charFormat);
            strippedText.remove(0, escapePos);
        }
//        QTC_ASSERT(strippedText.at(0) == escape.at(0), break);

        while (!strippedText.isEmpty() && escape.at(0) == strippedText.at(0)) {
            if (escape.startsWith(strippedText)) {
                // control secquence is not complete
                m_pendingText += strippedText;
                strippedText.clear();
                break;
            }
            if (!strippedText.startsWith(escape)) {
                switch (strippedText.at(1).toLatin1()) {
                case '\\': // Unexpected terminator sequence.
                    // QTC_CHECK(false);
                    Q_FALLTHROUGH();
                case 'N': case 'O': // Ignore unsupported single-character sequences.
                    strippedText.remove(0, 2);
                    break;
                case ']':
                    m_alternateTerminator = QChar(7);
                    Q_FALLTHROUGH();
                case 'P':  case 'X': case '^': case '_':
                    strippedText.remove(0, 2);
                    m_waitingForTerminator = true;
                    break;
                default:
                    // not a control sequence
                    m_pendingText.clear();
                    outputData << FormattedText(strippedText.left(1), charFormat);
                    strippedText.remove(0, 1);
                    continue;
                }
                break;
            }
            m_pendingText += strippedText.mid(0, escape.length());
            strippedText.remove(0, escape.length());

            // \e[K is not supported. Just strip it.
            if (strippedText.startsWith(eraseToEol)) {
                m_pendingText.clear();
                strippedText.remove(0, 1);
                continue;
            }
            // get the number
            QString strNumber;
            QStringList numbers;
            while (!strippedText.isEmpty()) {
                if (strippedText.at(0).isDigit()) {
                    strNumber += strippedText.at(0);
                } else {
                    if (!strNumber.isEmpty())
                        numbers << strNumber;
                    if (strNumber.isEmpty() || strippedText.at(0) != semicolon)
                        break;
                    strNumber.clear();
                }
                m_pendingText += strippedText.mid(0, 1);
                strippedText.remove(0, 1);
            }
            if (strippedText.isEmpty())
                break;

            // remove terminating char
            if (!strippedText.startsWith(colorTerminator)) {
                m_pendingText.clear();
                strippedText.remove(0, 1);
                break;
            }
            // got consistent control sequence, ok to clear pending text
            m_pendingText.clear();
            strippedText.remove(0, 1);

            if (numbers.isEmpty()) {
                charFormat = input.format;
                endFormatScope();
            }

            for (int i = 0; i < numbers.size(); ++i) {
                const uint code = numbers.at(i).toUInt();

                if (code >= TextColorStart && code <= TextColorEnd) {
                    charFormat.setForeground(ansiColor(code - TextColorStart));
                    setFormatScope(charFormat);
                } else if (code >= BackgroundColorStart && code <= BackgroundColorEnd) {
                    charFormat.setBackground(ansiColor(code - BackgroundColorStart));
                    setFormatScope(charFormat);
                } else {
                    switch (code) {
                    case ResetFormat:
                        charFormat = input.format;
                        endFormatScope();
                        break;
                    case BoldText:
                        charFormat.setFontWeight(QFont::Bold);
                        setFormatScope(charFormat);
                        break;
                    case DefaultTextColor:
                        charFormat.setForeground(input.format.foreground());
                        setFormatScope(charFormat);
                        break;
                    case DefaultBackgroundColor:
                        charFormat.setBackground(input.format.background());
                        setFormatScope(charFormat);
                        break;
                    case RgbTextColor:
                    case RgbBackgroundColor:
                        // See http://en.wikipedia.org/wiki/ANSI_escape_code#Colors
                        if (++i >= numbers.size())
                            break;
                        switch (numbers.at(i).toInt()) {
                        case 2:
                            // RGB set with format: 38;2;<r>;<g>;<b>
                            if ((i + 3) < numbers.size()) {
                                (code == RgbTextColor) ?
                                    charFormat.setForeground(QColor(numbers.at(i + 1).toInt(),
                                                                    numbers.at(i + 2).toInt(),
                                                                    numbers.at(i + 3).toInt())) :
                                    charFormat.setBackground(QColor(numbers.at(i + 1).toInt(),
                                                                    numbers.at(i + 2).toInt(),
                                                                    numbers.at(i + 3).toInt()));
                                setFormatScope(charFormat);
                            }
                            i += 3;
                            break;
                        case 5:
                            // 256 color mode with format: 38;5;<i>
                            uint index = numbers.at(i + 1).toUInt();

                            QColor color;
                            if (index < 8) {
                                // The first 8 colors are standard low-intensity ANSI colors.
                                color = ansiColor(index);
                            } else if (index < 16) {
                                // The next 8 colors are standard high-intensity ANSI colors.
                                color = ansiColor(index - 8).lighter(150);
                            } else if (index < 232) {
                                // The next 216 colors are a 6x6x6 RGB cube.
                                uint o = index - 16;
                                color = QColor((o / 36) * 51, ((o / 6) % 6) * 51, (o % 6) * 51);
                            } else {
                                // The last 24 colors are a greyscale gradient.
                                int grey = int((index - 232) * 11);
                                color = QColor(grey, grey, grey);
                            }

                            if (code == RgbTextColor)
                                charFormat.setForeground(color);
                            else
                                charFormat.setBackground(color);

                            setFormatScope(charFormat);
                            ++i;
                            break;
                        }
                        break;
                    default:
                        break;
                    }
                }
            }
        }
    }
    return outputData;
}

void AnsiEscapeCodeHandler::endFormatScope()
{
    m_previousFormatClosed = true;
}

void AnsiEscapeCodeHandler::setFormatScope(const QTextCharFormat &charFormat)
{
    m_previousFormat = charFormat;
    m_previousFormatClosed = false;
}
