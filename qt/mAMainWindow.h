#ifndef MAMAINWINDOW_H
#define MAMAINWINDOW_H

#include <QMainWindow>
#include <Qsci/qsciscintilla.h>
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

private:

    std::vector<mADocumentView *> documents;
    Ui::mAMainWindow *ui;
};

#endif // MAMAINWINDOW_H
