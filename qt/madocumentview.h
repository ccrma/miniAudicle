#ifndef MADOCUMENTVIEW_H
#define MADOCUMENTVIEW_H

#include <QWidget>
#include <QTabWidget>
#include <Qsci/qscilexer.h>

namespace Ui {
    class mADocumentView;
}

class mADocumentView : public QWidget
{
    Q_OBJECT

public:
    explicit mADocumentView(QWidget *parent = 0, std::string _title = std::string());
    ~mADocumentView();

    void setTabWidget(QTabWidget * _tabWidget);
    bool isDocumentModified();

public slots:
    void documentModified(bool modified);

protected:
    void showEvent( QShowEvent * event );

private:

    std::string title;
    QTabWidget * tabWidget;

    Ui::mADocumentView *ui;

    QsciLexer * lexer;
};

#endif // MADOCUMENTVIEW_H
