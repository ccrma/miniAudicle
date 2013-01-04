
#include "madocumentview.h"
#include "ui_madocumentview.h"

#include <QFileDialog>

#include <Qsci/qsciscintilla.h>
#include <Qsci/qscilexercpp.h>


class mAsciLexerChucK : public QsciLexerCPP
{
public:
    mAsciLexerChucK() : QsciLexerCPP()
    { }

    const char *keywords(int set) const
    {
        if(set == 0)
            return "int float time dur void same if else while do "
                   "until for break continue return switch repeat "
                   "class extends public static pure this "
                   "super interface implements protected "
                   "private function fun spork const new now "
                   "true false maybe null NULL me pi samp ms "
                   "second minute hour day week dac adc blackhole ";
        return 0;
    }

    const char *language() const { return "ChucK"; }
};


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
    lexer->setFont(QFont("Courier New", 11));
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
        file = new QFile(fileName);
        if(!file->open(QFile::ReadWrite | QFile::Text))
        {
            delete file;
            file = NULL;
        }

        QFileInfo fileInfo(fileName);
        setTitle(fileInfo.fileName().toStdString());
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
