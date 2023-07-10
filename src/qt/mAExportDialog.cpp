#include "mAExportDialog.h"
#include "ui_mAExportDialog.h"

#include "ZSettings.h"
#include "miniAudicle.h" // 1.5.0.7 (ge) added for platform macros

#include <QProcessEnvironment>
#include <QFileInfo>


mAExportDialog::mAExportDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::mAExportDialog)
{
    ui->setupUi(this);
    
    ZSettings settings;
    
    ui->limit->setChecked(settings.get("/Export/DoLimit", false).toBool());
    ui->duration->setValue((int)settings.get("/Export/Duration", 30.0).toFloat());
    
    ui->wavCheckbox->setChecked(true);
    ui->oggCheckbox->setChecked(false);
    ui->mp3Checkbox->setChecked(false);
    
    if(which("lame").length() > 0)
        ui->mp3Checkbox->setHidden(false);
    else
        ui->mp3Checkbox->setHidden(true);
    
    if(which("oggenc").length() > 0 || which("oggenc2").length() > 0)
        ui->oggCheckbox->setHidden(false);
    else
        ui->oggCheckbox->setHidden(true);
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

bool mAExportDialog::exportWAV()
{
    return ui->wavCheckbox->isChecked();
}

bool mAExportDialog::exportOgg()
{
    return ui->oggCheckbox->isChecked();
}

bool mAExportDialog::exportMP3()
{
    return ui->mp3Checkbox->isChecked();
}


QString which(const QString &bin)
{
    QProcessEnvironment env = QProcessEnvironment::systemEnvironment();
    
    QString pathVar = env.value("PATH");
#ifdef __PLATFORM_WINDOWS__
    QStringList paths = pathVar.split(';');
#else // not windows
    QStringList paths = pathVar.split(':');
#endif // __PLATFORM_WINDOWS__
    
    foreach(QString path, paths)
    {
        QString binPath = path + "/" + bin;
#ifdef __PLATFORM_WINDOWS__
        binPath += ".exe";
#endif
        QFileInfo binInfo(binPath);
        if(binInfo.exists() && binInfo.isExecutable())
            return binPath;
    }
    
#ifdef __PLATFORM_WINDOWS__
    QString binPath = QCoreApplication::applicationDirPath() + "/util/" + bin + ".exe";
    QFileInfo binInfo(binPath);
    if(binInfo.exists() && binInfo.isExecutable())
        return binPath;
#endif // __PLATFORM_WINDOWS__
    
    return "";
}

