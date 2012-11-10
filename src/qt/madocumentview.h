#ifndef MADOCUMENTVIEW_H
#define MADOCUMENTVIEW_H

#include <QWidget>
#include <QTabWidget>
#include <QFile>
#include <Qsci/qscilexer.h>

namespace Ui {
    class mADocumentView;
}

class mADocumentView : public QWidget
{
    Q_OBJECT

public:
    explicit mADocumentView(QWidget *parent = 0, std::string _title = std::string(), QFile * file = NULL);
    ~mADocumentView();

    void setTabWidget(QTabWidget * _tabWidget);
    bool isDocumentModified();

    void save();

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
};

#endif // MADOCUMENTVIEW_H
