#include "owncloudsync.h"

#include <QDir>
#include <QDebug>
#include <QStandardPaths>
#include <QCoreApplication>
#include <QNetworkConfigurationManager>


OwncloudSync::OwncloudSync(QObject *parent) : QObject(parent)
{

}

QString OwncloudSync::homePath(){

    return QDir::homePath();
}

QVariantList OwncloudSync::logPath(){

    QString logPath;

    logPath = homePath();
    logPath.append("/.cache/upstart/");

    QDir logFiles(logPath);

    //To Do: get entrylists for each log sorted by most recent.
    QStringList filters;
    filters << "owncloud-sync.log.1.gz" << "OwncloudSyncd.log";
    logFiles.setNameFilters(filters);
    //logFiles.setSorting(QDir::Time);

    QStringList logs = logFiles.entryList(QDir::NoDotAndDotDot | QDir::NoSymLinks | QDir::Files);
    QList<QVariant> variantlist;

    foreach(QString log, logs){
        log.prepend(logPath);
        variantlist << QVariant(log);
    }

    return variantlist;
}


bool OwncloudSync::newFolder(QString folderPath)
{

    if(folderPath.startsWith("file://"))
        folderPath = folderPath.replace("file://", "");

    QString path = folderPath; //getHomePath() + "/" + "New Folder";
    //QString folder = "New Folder";
    //QString folderPath = path;
    QDir dir;
    int number = 0;

    while(QDir(folderPath).exists()){
        number++;
        folderPath = path + " " + QString::number(number);
    }

    dir.mkdir(folderPath);

    //  if (!dir.exists()) {
    //      dir.mkpath(folderPath);
    //  }


    qDebug() << "Create New Folder: " << folderPath;

    return true;

}

void OwncloudSync::removeAllConfigs()
{
    //qDebug() << "homePath" << QDir::homePath();
    //qDebug() << "GenericConfigLocation" << QStandardPaths::GenericConfigLocation;
    //qDebug() << "AppConfigLocation" << QStandardPaths::AppConfigLocation;
    //qDebug() << "writableLocation" << QStandardPaths::writableLocation(QStandardPaths::ConfigLocation); // "/ubsync/owncloud-sync.conf";
    //qDebug() << "writableLocation" << QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation); // "/ubsync/Databases";
    //qDebug() << "applicationName" << QCoreApplication::applicationName();

    QString configPath = QDir::cleanPath(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + QDir::separator() +  QCoreApplication::applicationName());
    QString databasePath = QDir::cleanPath(QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation) + QDir::separator() +  QCoreApplication::applicationName());

    qDebug() << "OwncloudSync::removeAllConfigs" << "configPath" << configPath;
    qDebug() << "OwncloudSync::removeAllConfigs" << "databasePath" << databasePath;

    deleteAll(configPath);
    deleteAll(databasePath);

}

void OwncloudSync::deleteAll(QString path)
{
    qDebug() << "OwncloudSync::deleteAll" << path;
    QDir dir(path);
    dir.setFilter(QDir::Files | QDir::Dirs | QDir::NoDotAndDotDot);
    foreach(QString dirFile, dir.entryList())
    {
        qDebug() << "OwncloudSync::deleteAll - Delete:" << dirFile;

        QFileInfo dirFileInfo(path, dirFile);
        qDebug() << "OwncloudSync::deleteAll" << dirFileInfo.absoluteFilePath();

        if(dirFileInfo.isDir())
        {
            qDebug() << "OwncloudSync::deleteAll" << dirFile << "is a directory";
            deleteAll(dirFileInfo.absoluteFilePath());
        }else{
            dir.remove(dirFile);
        }
    }
}

bool OwncloudSync::networkAvailable(){

QNetworkConfigurationManager mgr;
qDebug() << "Network Connection Type: " << mgr.defaultConfiguration().bearerTypeName();

QList<QNetworkConfiguration> activeConfigs = mgr.allConfigurations(QNetworkConfiguration::Active);

return activeConfigs.count();

}

