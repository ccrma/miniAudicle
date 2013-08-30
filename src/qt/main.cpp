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

#include <QApplication>

#include "mAMainWindow.h"
#include "mASocketManager.h"

int main(int argc, char *argv[])
{    
    QApplication a(argc, argv);
    a.setStyle("windowsvista");
    
//    for(int i = 0; i < a.arguments().length(); i++)
//    {
//        fprintf(stderr, "arg: %s\n", a.arguments()[i].toUtf8().constData());
//        fflush(stderr);
//    }
    
    if(a.arguments().length() >= 2 && QFileInfo(a.arguments()[1]).exists())
    {
        fprintf(stderr, "[miniAudicle]: attempting to open file '%s' on remote\n", 
                a.arguments()[1].toUtf8().constData());
        fflush(stderr);
        if(mASocketManager::openFileOnRemote(a.arguments()[1]))
            return 0;
    }
    
    mAMainWindow w;
    w.show();

    return a.exec();
}
