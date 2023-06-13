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
//-----------------------------------------------------------------------------
// name: main.cpp
// desc: entry point file for Qt version of miniAudicle
//
// author: Spencer Salazar
// date: 2005-present
//-----------------------------------------------------------------------------
#include <QtWidgets/QApplication>
#include <QtWidgets/QStyleFactory>
#include <iostream>
using namespace std;

#include "mAMainWindow.h"
#include "mASocketManager.h"


//-----------------------------------------------------------------------------
// name: main()
// desc: the entry point
//-----------------------------------------------------------------------------
int main(int argc, char *argv[])
{
    // set style, e.g., Windows, windowsvista, Fusion, macos
    QApplication::setStyle( "windowsvista" );

    // get and print available styles
    // QStringList styles = QStyleFactory::keys();
    // for(QStringList::Iterator s = styles.begin(); s != styles.end(); s++ )
    //     qDebug( "[miniAudicle]: QStyle available: %s", qUtf8Printable(*s) );

    // Qt application initialization
    QApplication app(argc, argv);

    // argument to open file on remote
    if( app.arguments().length() >= 2 && QFileInfo(app.arguments()[1]).exists() )
    {
        // print
        cerr << "[miniAudicle]: attempting to open file '"
             << app.arguments()[1].toUtf8().constData()
             << "' on remote..." << endl;
        // open on remote
        if( mASocketManager::openFileOnRemote(app.arguments()[1]) )
            return 0;
    }

    // declare main miniAudicle window
    mAMainWindow w;
    // show
    w.show();

    // enter Qt run loop
    return app.exec();
}
