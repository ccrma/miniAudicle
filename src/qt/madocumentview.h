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

#ifndef MADOCUMENTVIEW_H
#define MADOCUMENTVIEW_H

#include <QWidget>
#include <QTabWidget>
#include <QFile>
#include <Qsci/qscilexer.h>

#include "miniAudicle.h"

namespace Ui {
    class mADocumentView;
}

class mADocumentView : public QWidget
{
    Q_OBJECT

public:
    explicit mADocumentView(QWidget *parent, std::string _title,
                            QFile * file, miniAudicle * ma);
    ~mADocumentView();
    void detach(); // workaround

    void setTabWidget(QTabWidget * _tabWidget);
    bool isDocumentModified();

    void save();

    void add();
    void replace();
    void remove();
    
    QString filePath()
    {
        if(file)
            return file->fileName();
        else
            return "";
    }

public slots:
    void documentModified(bool modified);

protected:
    void showEvent( QShowEvent * event );

private:

    void setTitle(std::string title);

    std::string title;
    QTabWidget * tabWidget;

    Ui::mADocumentView *ui;

    QsciLexer * lexer;

    QFile * file;

    miniAudicle * m_ma;
    t_CKUINT m_docid;
};

#endif // MADOCUMENTVIEW_H
