#ifndef MACONSOLEMONITOR_H
#define MACONSOLEMONITOR_H

#include <QMainWindow>
#include <QSocketNotifier>

namespace Ui {
class mAConsoleMonitor;
}

class mAConsoleMonitor : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit mAConsoleMonitor(QWidget *parent = 0);
    ~mAConsoleMonitor();
    
public slots:
    void appendFromFile(int fd);

private:
    Ui::mAConsoleMonitor *ui;

    int out_fd;
    int err_fd;

    QSocketNotifier * m_outNotifier, * m_errNotifier;
};

#endif // MACONSOLEMONITOR_H
