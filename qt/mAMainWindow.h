#ifndef MAMAINWINDOW_H
#define MAMAINWINDOW_H

#include <QMainWindow>

#include <vector>

#include "madocumentview.h"

namespace Ui {
    class mAMainWindow;
}

class mAMainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit mAMainWindow(QWidget *parent = 0);
    ~mAMainWindow();

public slots:

    void exit();

    void openFile();
    void newFile();
    void closeFile();
    void closeFile(int i);

private:

    std::vector<mADocumentView *> documents;
    Ui::mAMainWindow *ui;
};

#endif // MAMAINWINDOW_H
