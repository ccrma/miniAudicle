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
// file: ZSettings.cpp
// desc: setting utility
//
// author: Spencer Salazar (spencer@ccrma.stanford.edu)
//-----------------------------------------------------------------------------
#include "ZSettings.h"

// static instantiation
QMap<QString, QVariant> ZSettings::s_defaults;


//-----------------------------------------------------------------------------
// name: ZSettings()
// desc: constructor
//-----------------------------------------------------------------------------
ZSettings::ZSettings( QObject * parent )
    : QSettings( parent )
{ }


//-----------------------------------------------------------------------------
// name: setDefault()
// desc: set default
//-----------------------------------------------------------------------------
void ZSettings::setDefault( const QString & key, const QVariant & value )
{
    // set default
    s_defaults[key] = value;
}


//-----------------------------------------------------------------------------
// name: get()
// desc: get value by key
//-----------------------------------------------------------------------------
QVariant ZSettings::get( const QString & key, const QVariant & fallback )
{
    QSettings settings;
    // check settings
    if( settings.contains(key) )
        return settings.value(key);
    // if not found, check defaults
    if(s_defaults.contains(key))
        return s_defaults[key];
    // nothing found
    return fallback;
}

void ZSettings::set( const QString & key, const QVariant & value )
{
    QSettings settings;
    // set the value
    settings.setValue( key, value );
}
