#ifndef MAPREFERENCESWINDOW_H
#define MAPREFERENCESWINDOW_H

#include <QDialog>

namespace Ui {
class mAPreferencesWindow;
}

class mAPreferencesWindow : public QDialog
{
    Q_OBJECT
    
public:
    explicit mAPreferencesWindow(QWidget *parent = 0);
    ~mAPreferencesWindow();
    
public slots:
    
    void ok();
    void cancel();
    void restoreDefaults();
    
private:
    Ui::mAPreferencesWindow *ui;
};

#endif // MAPREFERENCESWINDOW_H
