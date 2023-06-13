/*----------------------------------------------------------------------------
miniAudicle:
  integrated developement environment for ChucK audio programming language

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
// file: ZSettings.h
// desc: setting utility
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
//-----------------------------------------------------------------------------
#ifndef ZSETTINGS_H
#define ZSETTINGS_H

#include <QSettings>


//-----------------------------------------------------------------------------
// name: class ZSetting
// desc: settings class
//-----------------------------------------------------------------------------
class ZSettings : public QSettings
{
    Q_OBJECT

public:
    // constructor
    explicit ZSettings( QObject * parent = 0 );

public:
    // set value
    void set( const QString & key, const QVariant & value );
    // get a value by key
    QVariant get( const QString & key, const QVariant & fallback = QVariant() );

public:
    // set defeault
    static void setDefault( const QString & key, const QVariant & value );

private:
    // the default map
    static QMap<QString, QVariant> s_defaults;
};


#endif // ZSETTINGS_H
