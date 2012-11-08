
#include <QApplication>

#include "mAMainWindow.h"

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    mAMainWindow w;
    w.show();

    return a.exec();
}
