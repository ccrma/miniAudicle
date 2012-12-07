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

    void setTabWidget(QTabWidget * _tabWidget);
    bool isDocumentModified();

    void save();

    void add();
    void replace();
    void remove();

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
