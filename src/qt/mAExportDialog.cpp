#include "mAExportDialog.h"
#include "ui_mAExportDialog.h"

#include <QSettings>


mAExportDialog::mAExportDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::mAExportDialog)
{
    ui->setupUi(this);
    
    QSettings settings;
    
    ui->limit->setChecked(settings.value("/Export/DoLimit", false).toBool());
    ui->duration->setValue((int)settings.value("/Export/Duration", 30.0).toFloat());
}

mAExportDialog::~mAExportDialog()
{
    QSettings settings;
    
    settings.setValue("/Export/DoLimit", ui->limit->isChecked());
    settings.setValue("/Export/Duration", (float)ui->duration->value());
    
    delete ui;
}


bool mAExportDialog::doLimit()
{
    return ui->limit->isChecked();
}

float mAExportDialog::limitDuration()
{
    return ui->duration->value();
}
