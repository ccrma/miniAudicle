#ifndef MADOCUMENTVIEW_H
#define MADOCUMENTVIEW_H

#include <QWidget>

namespace Ui {
    class mADocumentView;
}

class mADocumentView : public QWidget
{
    Q_OBJECT

public:
    explicit mADocumentView(QWidget *parent = 0);
    ~mADocumentView();


protected:
    void resizeEvent( QResizeEvent * event );

private:
    Ui::mADocumentView *ui;
};

#endif // MADOCUMENTVIEW_H
