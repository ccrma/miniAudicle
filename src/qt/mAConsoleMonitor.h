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
#include <QPlainTextEdit>

#ifdef __PLATFORM_WIN32__
#include <windows.h>
#endif

namespace Ui {
class mAConsoleMonitor;
}

class miniAudicle;
class mAConsoleMonitorThread;
class AnsiEscapeCodeHandler;




//-----------------------------------------------------------------------------
// name: class mAConsoleMonitor
// desc: controller for VM console monitor window
//-----------------------------------------------------------------------------
class mAConsoleMonitor : public QMainWindow
{
    Q_OBJECT
    
public:
    // constructor
    explicit mAConsoleMonitor(QWidget *parent, miniAudicle * ma);
    // destructor
    ~mAConsoleMonitor();

    // err callback redirect coming from chuck
    void ckErrOutCallback(const char *str);

public slots:
    // append file contents to output
    void appendFromFile(int fd);
    // called when data available to append
    void dataAvailable();

private:
    // the ui
    Ui::mAConsoleMonitor * ui;
    // miniAudicle reference
    miniAudicle * ma_ref;

#ifdef __PLATFORM_WIN32__
    HANDLE hRead, hWrite;
#endif
    // file descriptors
    int read_fd;
    int write_fd;

    // notifier
    QSocketNotifier * m_notifier;
    // 1.5.0.6 (ge) adde
    AnsiEscapeCodeHandler * m_esc2text;

    // friend!
    friend class mAConsoleMonitorThread;
};


// console monitor thread
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




//-----------------------------------------------------------------------------
// name: class mAPlainTextEdit
// desc: custom plain text edit; used as promoted class for mAConsoleMonitor.ui
//       1.5.0.4 (ge) added
//-----------------------------------------------------------------------------
class mAPlainTextEdit : public QPlainTextEdit
{
    Q_OBJECT

public:
    explicit mAPlainTextEdit( QWidget *parent );
    virtual ~mAPlainTextEdit();

protected:
    // override context menu event to customize it
    virtual void contextMenuEvent( QContextMenuEvent * event );
};




//-----------------------------------------------------------------------------
// in search of a VT100 color printing
//
// Copyright (C) 2016 Petar Perisin <petar.perisin@gmail.com>
// LicenseRef-Qt-Commercial OR GPL-3.0-only WITH Qt-GPL-exception-1.0
//
// https://forum.qt.io/topic/96638/qplaintextedit-vt100-espace-sequence-support
// https://code.qt.io/cgit/qt-creator/qt-creator.git/tree/src/libs/utils/ansiescapecodehandler.h
// https://code.qt.io/cgit/qt-creator/qt-creator.git/tree/src/libs/utils/ansiescapecodehandler.cpp
//-----------------------------------------------------------------------------
class FormattedText
{
public:
    FormattedText() = default;
    FormattedText(const QString &txt, const QTextCharFormat &fmt = QTextCharFormat()) :
        text(txt), format(fmt)
    { }

    QString text;
    QTextCharFormat format;
};

class AnsiEscapeCodeHandler
{
public:
    QList<FormattedText> parseText(const FormattedText &input);
    void endFormatScope();

private:
    void setFormatScope(const QTextCharFormat &charFormat);

    bool            m_previousFormatClosed = true;
    bool            m_waitingForTerminator = false;
    QString         m_alternateTerminator;
    QTextCharFormat m_previousFormat;
    QString         m_pendingText;
};




#endif // MACONSOLEMONITOR_H
