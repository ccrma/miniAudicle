#include "madocumentview.h"
#include "ui_madocumentview.h"

mADocumentView::mADocumentView(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::mADocumentView)
{
    ui->setupUi(this);
}

mADocumentView::~mADocumentView()
{
    delete ui;
}

void mADocumentView::resizeEvent( QResizeEvent * event )
{
    QWidget::resizeEvent(event);
    QSize r = this->frameSize();
    ui->textEdit->resize(r);
}
