#ifndef MAMAINWINDOW_H
#define MAMAINWINDOW_H

#include <QMainWindow>
#include <QFile>
#include <QFileDialog>

#include <list>

#include "madocumentview.h"

#include "miniAudicle.h"

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

    void openFile(const QString &path = QString());
    void newFile();
    void closeFile();
    void closeFile(int i);
    void saveFile();

    void addCurrentDocument();
    void replaceCurrentDocument();
    void removeCurrentDocument();
    void toggleVM();

private:

    Ui::mAMainWindow *ui;
    std::list<mADocumentView *> documents;
    bool vm_on;

    miniAudicle * ma;
};

#endif // MAMAINWINDOW_H