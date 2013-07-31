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


#include "mASocketManager.h"

#include "mAMainWindow.h"

const QString MA_LOCAL_SERVER_NAME = "miniAudicle";

mASocketManager::mASocketManager(mAMainWindow * mainWindow, QObject *parent) :
    QObject(parent),
    m_mainWindow(mainWindow)
{
    m_server = NULL;
}

void mASocketManager::startServer()
{
    if(m_server != NULL)
        return;
    
    QLocalServer::removeServer(MA_LOCAL_SERVER_NAME);
    
    m_server = new QLocalServer;
    if(!m_server->listen(MA_LOCAL_SERVER_NAME))
    {
        // error
    }
    
    QObject::connect(m_server, SIGNAL(newConnection()), this, SLOT(newConnection()));
}

void mASocketManager::newConnection()
{
    //fprintf(stderr, "[miniAudicle]: received connection from remote\n");
    fflush(stderr);
    
    QLocalSocket * socket = m_server->nextPendingConnection();
    
    QByteArray data;
    QString path;
    int timeouts = 0;
    
    while(timeouts < 4)
    {
        if(socket->bytesAvailable() <= 0 && !socket->waitForReadyRead(500))
            timeouts++;
        else
        {
            QByteArray bytes = socket->readAll();
            data.append(bytes);
            
            bytes.append('\0');
            //fprintf(stderr, "[miniAudicle]: received data '%s'\n", bytes.constData());
            
            // check for line ending
            if(data.at(data.length()-1) == '\n')
            {
                path = QString(data);
                // remove trailing \n
                path.remove(path.length()-1, 1);
                
                socket->close();
                socket = NULL;
                break;
            }
        }
    }
    
    if(path.length())
    {
        if(QFileInfo(path).exists())
        {
            //fprintf(stderr, "[miniAudicle]: received path '%s' from remote\n", path.toUtf8().constData());
            fflush(stderr);
            m_mainWindow->openFile(path);
        }
    }
}

bool mASocketManager::openFileOnRemote(const QString &_path)
{
    bool r = false;
    
    QString path = QFileInfo(_path).canonicalFilePath();
    path.append('\n');
    
    QLocalSocket socket;
    socket.connectToServer(MA_LOCAL_SERVER_NAME);
    
    if(socket.waitForConnected(1000))
    {
        socket.write(path.toUtf8());
        socket.flush();
        r = true;
    }
    
    socket.close();
    
    return r;
}

