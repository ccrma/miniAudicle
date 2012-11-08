
#include "madocumentview.h"
#include "ui_madocumentview.h"

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


mADocumentView::mADocumentView(QWidget *parent, std::string _title) :
    QWidget(parent),
    ui(new Ui::mADocumentView),
    tabWidget(NULL)
{
    ui->setupUi(this);

    title = _title;

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
}

mADocumentView::~mADocumentView()
{
    delete ui;
    delete lexer;
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

void mADocumentView::documentModified(bool modified)
{
    if(isDocumentModified())
        tabWidget->setTabText(tabWidget->indexOf(this), QString(std::string(title + "*").c_str()));
    else
        tabWidget->setTabText(tabWidget->indexOf(this), QString(title.c_str()));
}

