#ifndef MAMAINWINDOW_H
#define MAMAINWINDOW_H

#include <QMainWindow>

namespace Ui {
    class mAMainWindow;
}

class mAMainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit mAMainWindow(QWidget *parent = 0);
    ~mAMainWindow();

private:
    Ui::mAMainWindow *ui;
};

#endif // MAMAINWINDOW_H
