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

#include "madocumentview.h"
#include "ui_madocumentview.h"

#include <QFileDialog>

#include <Qsci/qsciscintilla.h>
#include "mAsciLexerChucK.h"


mADocumentView::mADocumentView(QWidget *parent, std::string _title, QFile * file, miniAudicle * ma) :
    QWidget(parent),
    ui(new Ui::mADocumentView),
    tabWidget(NULL),
    m_ma(ma)
{
    ui->setupUi(this);

    title = _title;

    if(file != NULL)
        ui->textEdit->read(file);
    this->file = file;

    ui->textEdit->setMarginLineNumbers(1, true);
    ui->textEdit->setMarginsFont(QFont("Courier New", 9));
    ui->textEdit->setMarginWidth(1, "     ");

    ui->textEdit->setTabIndents(true);
    ui->textEdit->setIndentationsUseTabs(false);
    ui->textEdit->setTabWidth(4);

    lexer = new mAsciLexerChucK();
    ui->textEdit->setLexer(lexer);

    ui->textEdit->setBraceMatching(QsciScintilla::SloppyBraceMatch);
    ui->textEdit->setAutoIndent(true);

    m_docid = m_ma->allocate_document_id();
}

mADocumentView::~mADocumentView()
{
    detach();

    delete ui;
    ui = NULL;
    delete lexer;
    lexer = NULL;
}

void mADocumentView::detach()
{
    if(m_ma)
    {
        m_ma->free_document_id(m_docid);
        m_ma = NULL;
    }
}

void mADocumentView::setTabWidget(QTabWidget * _tabWidget)
{
    tabWidget = _tabWidget;
    if(isDocumentModified())
        tabWidget->setTabText(tabWidget->indexOf(this), QString(std::string(title + "*").c_str()));
    else
        tabWidget->setTabText(tabWidget->indexOf(this), QString(title.c_str()));
}

void mADocumentView::showEvent( QShowEvent * event )
{
    ui->textEdit->setFocus();
}

bool mADocumentView::isDocumentModified()
{
    return ui->textEdit->isModified();
}

void mADocumentView::setTitle(std::string _title)
{
    title = _title;
    if(tabWidget != NULL)
    {
        if(isDocumentModified())
            tabWidget->setTabText(tabWidget->indexOf(this), QString(std::string(title + "*").c_str()));
        else
            tabWidget->setTabText(tabWidget->indexOf(this), QString(title.c_str()));
    }
}

void mADocumentView::documentModified(bool modified)
{
    if(tabWidget != NULL)
    {
        if(isDocumentModified())
            tabWidget->setTabText(tabWidget->indexOf(this), QString(std::string(title + "*").c_str()));
        else
            tabWidget->setTabText(tabWidget->indexOf(this), QString(title.c_str()));
    }
}

void mADocumentView::save()
{
    if(file == NULL)
    {
        QString fileName = QFileDialog::getSaveFileName(this,
            tr("Save File"), "", "ChucK Scripts (*.ck)");

        if(fileName != NULL && fileName.length() > 0)
        {
            file = new QFile(fileName);

            if(file->open(QFile::ReadWrite | QFile::Text))
            {
                QFileInfo fileInfo(fileName);
                setTitle(fileInfo.fileName().toStdString());
            }
            else
            {
                delete file;
                file = NULL;
            }
        }
    }

    if(file != NULL)
    {
        ui->textEdit->write(file);
        ui->textEdit->setModified(false);
        documentModified(false);
    }
}

void mADocumentView::add()
{
    vector<string> args;
    string filepath;
    if(file != NULL) filepath = file->fileName().toStdString();
    string output;
    t_CKUINT shred_id;
    string code = ui->textEdit->text().toStdString();

    m_ma->run_code(code, this->title, args,
                   filepath, m_docid, shred_id, output);
}

void mADocumentView::replace()
{
    vector<string> args;
    string filepath;
    if(file != NULL) filepath = file->fileName().toStdString();
    string output;
    t_CKUINT shred_id;
    string code = ui->textEdit->text().toStdString();

    m_ma->replace_code(code, this->title, args,
                       filepath, m_docid, shred_id, output);
}

void mADocumentView::remove()
{
    string output;
    t_CKUINT shred_id;

    m_ma->remove_code(m_docid, shred_id, output);
}
