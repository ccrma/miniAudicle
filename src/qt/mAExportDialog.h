#ifndef MAEXPORTDIALOG_H
#define MAEXPORTDIALOG_H

#include <QDialog>

namespace Ui {
class mAExportDialog;
}

class mAExportDialog : public QDialog
{
    Q_OBJECT
    
public:
    explicit mAExportDialog(QWidget *parent = 0);
    ~mAExportDialog();
    
    bool doLimit();
    float limitDuration();
    
private:
    Ui::mAExportDialog *ui;
};

#endif // MAEXPORTDIALOG_H
