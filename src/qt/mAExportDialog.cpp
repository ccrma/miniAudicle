#include "mAExportDialog.h"
#include "ui_mAExportDialog.h"

#include "ZSettings.h"


mAExportDialog::mAExportDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::mAExportDialog)
{
    ui->setupUi(this);
    
    ZSettings settings;
    
    ui->limit->setChecked(settings.get("/Export/DoLimit", false).toBool());
    ui->duration->setValue((int)settings.get("/Export/Duration", 30.0).toFloat());
}

mAExportDialog::~mAExportDialog()
{
    ZSettings settings;
    
    settings.set("/Export/DoLimit", ui->limit->isChecked());
    settings.set("/Export/Duration", (float)ui->duration->value());
    
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
