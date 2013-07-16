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
#include <QMessageBox>
#include <QTemporaryFile>
#include <QResource>
#include <QProcess>
#include <QThread>
#include <Qsci/qsciscintilla.h>

#include "mAsciLexerChucK.h"
#include "mAExportDialog.h"

#include "util_string.h"


mADocumentView::mADocumentView(QWidget *parent, std::string _title, QFile * file, miniAudicle * ma) :
    QWidget(parent),
    ui(new Ui::mADocumentView),
    tabWidget(NULL),
    m_ma(ma)
{
    ui->setupUi(this);

    m_title = _title;

    if(file != NULL)
    {
        file->open(QIODevice::ReadOnly);
        ui->textEdit->read(file);
        file->close();
        this->file = file;
    }
    ui->textEdit->setModified(false);
    m_readOnly = false;

    ui->textEdit->setMarginLineNumbers(1, true);
    ui->textEdit->setMarginsFont(QFont("Courier New", 10));
    ui->textEdit->setMarginWidth(1, "     ");

    ui->textEdit->setAutoIndent(true);
    ui->textEdit->setTabIndents(true);
    ui->textEdit->setIndentationsUseTabs(false);
    ui->textEdit->setTabWidth(4);

    lexer = new mAsciLexerChucK();
    ui->textEdit->setLexer(lexer);

    ui->textEdit->setBraceMatching(QsciScintilla::SloppyBraceMatch);
    
//    m_indicator = ui->textEdit->indicatorDefine(QsciScintilla::RoundBoxIndicator);
//    ui->textEdit->setIndicatorDrawUnder(true, m_indicator);
//    ui->textEdit->setIndicatorForegroundColor(QColor(0xFF, 0x00, 0x00, 0x40), m_indicator);
//    ui->textEdit->setIndicatorOutlineColor(QColor(0xFF, 0x00, 0x00, 0x40), m_indicator);

    m_docid = m_ma->allocate_document_id();
}

mADocumentView::~mADocumentView()
{
    detach();
    
    SAFE_DELETE(file);
    SAFE_DELETE(lexer);
    SAFE_DELETE(ui);
}

void mADocumentView::preferencesChanged()
{
    ((mAsciLexerChucK *)ui->textEdit->lexer())->preferencesChanged();
//    ui->textEdit->recolor();
}

void mADocumentView::exportAsWav()
{
    QString dir;
    if(file)
    {
        QFileInfo fileinfo(*file);
        dir = fileinfo.dir().absolutePath() + "/" + fileinfo.completeBaseName() + ".wav";
    }
    
    QString filename = QFileDialog::getSaveFileName(this, "Export as WAV", dir, "WAV files (*.wav)");
    
    if(filename.length() > 0)
    {
        mAExportDialog exportDialog;
        
        exportDialog.exec();
        
        QTemporaryFile exportScript(QDir::tempPath() + "/exportXXXXXX.ck");
        exportScript.open();
        QResource exportResource(":/scripts/export.ck");
        exportScript.write((const char *)exportResource.data(), exportResource.size());
        exportScript.flush();
        exportScript.close();
        
        QTemporaryFile runScript(QDir::tempPath() + "/runXXXXXX.ck");
        runScript.open();
        ui->textEdit->write(&runScript);
        runScript.flush();
        runScript.close();
        
        QString exportScriptFilename = exportScript.fileName().replace(':', "\\:");
        QString runScriptFilename = runScript.fileName().replace(':', "\\:");
        filename = filename.replace(':', "\\:");
        
        
        QString arg = QString("%1:%2:%3:%4:%5").
                arg(exportScriptFilename).
                arg(runScriptFilename).
                arg(filename).
                arg(exportDialog.doLimit() ? 1 : 0).
                arg(exportDialog.limitDuration());
        
        fprintf(stderr, "%s\n", arg.toAscii().constData());
        fflush(stderr);
        
        QProcess process;
        QStringList args; args.append("--silent"); args.append(arg);
        process.setProcessChannelMode(QProcess::ForwardedChannels);
        process.start("chuck", args);
        
        //process.waitForFinished(-1);
        
        QProgressDialog progress("Exporting", "Cancel", 0, 0, this);
        progress.setWindowModality(Qt::WindowModal);
        progress.setValue(0);
        
        progress.show();
   
        bool cancelled = false;
        while(true)
        {
            if(progress.wasCanceled())
            {
                cancelled = true;
                break;
            }
            
            if(process.waitForFinished(10))
                break;
            
            QCoreApplication::processEvents(QEventLoop::AllEvents, 10);
        }
        
        if(cancelled)
        {
#ifdef __PLATFORM_WIN32__
            AttachConsole((DWORD)process.pid()); // attach to process console
            SetConsoleCtrlHandler(NULL, TRUE); // disable Control+C handling for our app
            GenerateConsoleCtrlEvent(CTRL_C_EVENT, 0); // generate Control+C event
#else
            kill(process.pid(), SIGINT);
#endif
        }
        
        process.waitForFinished(1000);
        
        progress.hide();        
    }
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
        tabWidget->setTabText(tabWidget->indexOf(this), QString(std::string(m_title + "*").c_str()));
    else
        tabWidget->setTabText(tabWidget->indexOf(this), QString(m_title.c_str()));
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
    m_title = _title;
    if(tabWidget != NULL)
    {
        if(isDocumentModified())
            tabWidget->setTabText(tabWidget->indexOf(this), QString(std::string(m_title + "*").c_str()));
        else
            tabWidget->setTabText(tabWidget->indexOf(this), QString(m_title.c_str()));
    }
}

void mADocumentView::documentModified(bool modified)
{
    if(tabWidget != NULL)
    {
        if(isDocumentModified())
            tabWidget->setTabText(tabWidget->indexOf(this), QString(std::string(m_title + "*").c_str()));
        else
            tabWidget->setTabText(tabWidget->indexOf(this), QString(m_title.c_str()));
    }
}

void mADocumentView::save()
{
    if(m_readOnly)
    {
        QMessageBox * messageBox = new QMessageBox(this);
        QString qtitle = QString(this->m_title.c_str());
        
        messageBox->window()->setWindowFlags(Qt::Dialog | Qt::WindowTitleHint | Qt::CustomizeWindowHint);
        messageBox->window()->setAttribute(Qt::WA_DeleteOnClose);
        messageBox->window()->setWindowIcon(this->window()->windowIcon());
        
        messageBox->setIcon(QMessageBox::Warning);
        messageBox->setText(QString("<b>The document '%1' is read-only.</b><br /><br /> Click Save As to save the document to a different file. Click Cancel to cancel the save operation.").arg(qtitle));
        
        messageBox->setDefaultButton(messageBox->addButton("Save As...", QMessageBox::AcceptRole));
        messageBox->addButton("Cancel", QMessageBox::RejectRole);
        
        QObject::connect(messageBox, SIGNAL(buttonClicked(QAbstractButton*)),
                         this, SLOT(readOnlySaveDialogClicked(QAbstractButton*)));
                                            
        messageBox->show();
        
        return;
    }
    
    if(file == NULL)
    {
        QString fileName = QFileDialog::getSaveFileName(this,
            tr("Save File"), "", "ChucK Scripts (*.ck)");

        // SPENCERTODO: note file in Recent Files menu        
        if(fileName != NULL && fileName.length() > 0)
        {
            file = new QFile(fileName);

            if(file->open(QFile::ReadWrite))
            {
                // don't leave it open -- is reopened for each transaction                
                file->close();
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
        file->open(QIODevice::WriteOnly | QIODevice::Truncate);
        ui->textEdit->write(file);
        file->flush();
        file->close();
        ui->textEdit->setModified(false);
        documentModified(false);
    }
}


void mADocumentView::readOnlySaveDialogClicked(QAbstractButton *button)
{
    QMessageBox * messageBox = (QMessageBox *) sender();
    if(messageBox->buttonRole(button) == QMessageBox::AcceptRole)
        this->saveAs();
}

void mADocumentView::saveAs()
{
    QFile * oldFile = NULL;
    QString fileName = QFileDialog::getSaveFileName(this, tr("Save File"), "", "ChucK Scripts (*.ck)");
    
    if(fileName != NULL && fileName.length() > 0)
    {
        oldFile = file;
        m_readOnly = false;
        file = new QFile(fileName);
        
        // SPENCERTODO: note file in Recent Files menu
        if(file->open(QFile::ReadWrite))
        {
            // don't leave it open -- is reopened for each transaction
            file->close();
            QFileInfo fileInfo(fileName);
            setTitle(fileInfo.fileName().toStdString());
        }
        else
        {
            delete file;
            file = NULL;
        }
    }

    if(file != NULL)
    {
        file->open(QIODevice::WriteOnly | QIODevice::Truncate);
        ui->textEdit->write(file);
        file->flush();
        file->close();
        ui->textEdit->setModified(false);
        documentModified(false);
    }
    
    if(oldFile != NULL)
        delete oldFile;
}



void mADocumentView::add()
{
    string argString = (QString("filename:") + ui->arguments->text()).toStdString();
    string _filename;    
    vector<string> argv;
    if(!extract_args(argString, _filename, argv))
        argv.clear();
    
    string filepath;
    if(file != NULL) filepath = file->fileName().toStdString();
    else filepath = QDir::currentPath().toStdString();
    string output;
    t_CKUINT shred_id;
    string code = ui->textEdit->text().toStdString();

    t_OTF_RESULT otf_result = m_ma->run_code(code, m_title, argv,
                                             filepath, m_docid, shred_id, output);
    
    if(otf_result == OTF_SUCCESS)
    {
        m_lastResult = "";
        ui->textEdit->clearIndicatorRange(0, 0, ui->textEdit->lines(), 
                                          ui->textEdit->lineLength(ui->textEdit->lines()-1)-1,
                                          m_indicator);
    }
    else if( otf_result == OTF_VM_TIMEOUT )
    {
//        miniAudicleController * mac = [NSDocumentController sharedDocumentController];
//        [mac setLockdown:YES];
    }
    else if( otf_result == OTF_COMPILE_ERROR )
    {
        int error_line;
        if( m_ma->get_last_result( m_docid, NULL, NULL, &error_line ) )
        {
//            ui->textEdit->fillIndicatorRange(error_line, 0, error_line+1, 0,
//                                             //ui->textEdit->lineLength(error_line)-1,
//                                             m_indicator);
        }
        
//        if([self.windowController currentViewController] == self)
//            [[text_view textView] animateError];
        
        m_lastResult = output;
    }
    
    else
    {
//        if([self.windowController currentViewController] == self)
//            [[text_view textView] animateError];
        
        m_lastResult = output;        
    }
}

void mADocumentView::replace()
{
    string argString = (QString("filename:") + ui->arguments->text()).toStdString();
    string _filename;    
    vector<string> argv;
    if(!extract_args(argString, _filename, argv))
        argv.clear();
    
    string filepath;
    if(file != NULL) filepath = file->fileName().toStdString();
    else filepath = QDir::currentPath().toStdString();
    string output;
    t_CKUINT shred_id;
    string code = ui->textEdit->text().toStdString();

    t_OTF_RESULT otf_result = m_ma->replace_code(code, m_title, argv,
                                                 filepath, m_docid, shred_id, output);
    
    if(otf_result == OTF_SUCCESS)
    {
        m_lastResult = "";
        ui->textEdit->clearIndicatorRange(0, 0, ui->textEdit->lines()-1, 
                                          ui->textEdit->lineLength(ui->textEdit->lines()-1)-1,
                                          m_indicator);        
    }
    else if( otf_result == OTF_VM_TIMEOUT )
    {
//        miniAudicleController * mac = [NSDocumentController sharedDocumentController];
//        [mac setLockdown:YES];
    }
    else if( otf_result == OTF_COMPILE_ERROR )
    {
        int error_line;
        if( m_ma->get_last_result( m_docid, NULL, NULL, &error_line ) )
        {
//            [text_view setShowsErrorLine:YES];
//            [text_view setErrorLine:error_line];
        }
        
//        if([self.windowController currentViewController] == self)
//            [[text_view textView] animateError];
        
        m_lastResult = output;
    }
    
    else
    {
//        if([self.windowController currentViewController] == self)
//            [[text_view textView] animateError];
        
        m_lastResult = output;        
    }
}

void mADocumentView::remove()
{
    string output;
    t_CKUINT shred_id;

    t_OTF_RESULT otf_result = m_ma->remove_code(m_docid, shred_id, output);
    
    if(otf_result == OTF_SUCCESS)
    {
        m_lastResult = "";
        ui->textEdit->clearIndicatorRange(0, 0, ui->textEdit->lines()-1, 
                                          ui->textEdit->lineLength(ui->textEdit->lines()-1)-1,
                                          m_indicator);        
    }
    else if( otf_result == OTF_VM_TIMEOUT )
    {
//        miniAudicleController * mac = [NSDocumentController sharedDocumentController];
//        [mac setLockdown:YES];
    }
    else
    {
//        if([self.windowController currentViewController] == self)
//            [[text_view textView] animateError];
        
        m_lastResult = output;        
    }    
}
