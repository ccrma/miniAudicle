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

#include <QtWidgets/QMainWindow>
#include <QFile>
#include <QtWidgets/QFileDialog>

#include <list>

#include "miniAudicle.h"

class mADocumentView;
class mAConsoleMonitor;
class mAVMMonitor;
class mAPreferencesWindow;
class mASocketManager;
class mADeviceBrowser;

namespace Ui {
class mAMainWindow;
}

class mAMainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit mAMainWindow(QWidget *parent = 0);
    ~mAMainWindow();
    
    void setLockdown(bool _lockdowned);
    bool lockdown() { return m_lockdown; }

public slots:

    void exit();
    void about();

    void openFile(const QString &path = QString());
    void openRecent();
    void openExample();
    void newFile();
    void closeFile();
    void closeFile(int i);
    void saveFile();
    void saveAs();
    void tabSelected(int index);

    void addCurrentDocument();
    void replaceCurrentDocument();
    void removeCurrentDocument();
    void removeLastShred();
    void removeAllShreds();
    void clearVM();
    
    void abortCurrentShred();
    void toggleVM();
    void setLogLevel();
    
    void showPreferences();
    
    void showConsoleMonitor();
    void showVirtualMachineMonitor();
    void showDeviceBrowser();

protected:
    void closeEvent(QCloseEvent *);
    bool performClose(int i);
    bool shouldCloseOrQuit();
    
private:

    Ui::mAMainWindow *ui;
    std::list<mADocumentView *> documents;
    bool vm_on;

    mAConsoleMonitor * m_consoleMonitor;
    mAVMMonitor * m_vmMonitor;
    mAPreferencesWindow * m_preferencesWindow;
    mADeviceBrowser * m_deviceBrowser;

    mASocketManager * m_socketManager;
    
    miniAudicle * ma;
    t_CKUINT m_docid;
    bool m_lockdown;
    
    void addRecentFile(QString &path);
    void updateRecentFilesMenu();
};

#endif // MAMAINWINDOW_H
