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

#ifndef MAMAINWINDOW_H
#define MAMAINWINDOW_H

#include <QMainWindow>
#include <QFile>
#include <QFileDialog>

#include <list>

#include "miniAudicle.h"

class mADocumentView;
class mAConsoleMonitor;
class mAVMMonitor;

namespace Ui {
class mAMainWindow;
}

class mAMainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit mAMainWindow(QWidget *parent = 0);
    ~mAMainWindow();

public slots:

    void exit();
    void about();

    void openFile(const QString &path = QString());
    void openRecent();
    void newFile();
    void closeFile();
    void closeFile(int i);
    void saveFile();

    void addCurrentDocument();
    void replaceCurrentDocument();
    void removeCurrentDocument();
    void removeLastShred();
    void removeAllShreds();
    void toggleVM();
    
    void showConsoleMonitor();
    void showVirtualMachineMonitor();

private:

    Ui::mAMainWindow *ui;
    std::list<mADocumentView *> documents;
    bool vm_on;

    mAConsoleMonitor * m_consoleMonitor;
    mAVMMonitor * m_vmMonitor;

    miniAudicle * ma;
    t_CKUINT m_docid;
    
    void addRecentFile(QString &path);
    void updateRecentFilesMenu();
};

#endif // MAMAINWINDOW_H
