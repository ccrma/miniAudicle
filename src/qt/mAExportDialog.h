#ifndef MAEXPORTDIALOG_H
#define MAEXPORTDIALOG_H

#include <QtWidgets/QDialog>


extern QString which(const QString &bin);


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
    
    bool exportWAV();
    bool exportOgg();
    bool exportMP3();
    
private:
    Ui::mAExportDialog *ui;
};

#endif // MAEXPORTDIALOG_H
