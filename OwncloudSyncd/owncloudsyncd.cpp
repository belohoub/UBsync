#include <QCoreApplication>
#include <QDebug>
#include <QProcess>
#include <QSettings>
#include <QStandardPaths>
#include <QDateTime>
#include <QDir>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QUrl>
#include <QNetworkConfigurationManager>

#include <QtDBus/QtDBus>


#include "owncloudsyncd.h"

OwncloudSyncd::OwncloudSyncd()
{

    //QCoreApplication::setApplicationName("owncloud-sync");
    QCoreApplication::setApplicationName("owncloud-sync");
    QDBusConnection::sessionBus().registerService("org.owncloudsyncd");
    QDBusConnection::sessionBus().registerObject("/org/owncloudsyncd/Controller", this, QDBusConnection::ExportScriptableSlots|QDBusConnection::ExportScriptableSignals);

    qDebug() << "[owncloudsyncd](OwncloudSyncd::OwncloudSyncd()) - Registering with dbus";


    m_settingsFile =  QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/ubsync/ubsync.conf";

    if( !QFile(m_settingsFile).exists()){
        qDebug() << "No Settings File - Quiting";
        //QCoreApplication::quit();
    }

    qDebug() << QString("Retrieve settings from ") + m_settingsFile;

    QSettings settings(m_settingsFile, QSettings::IniFormat);

    m_username = settings.value("username").toString();
    m_password = settings.value("password").toString();
    m_serverURL = settings.value("serverURL").toString();
    m_mobileData = settings.value("mobileData").toBool();
    //m_syncInterval = settings.value("timer").toInt() * 60 * 1000 ;
    m_syncInterval = settings.value("timer").toInt() * 3600 * 1000 ;
    m_lastSync = settings.value("lastSync").toInt();

    //qDebug() << "Username: " << m_username << " Server: " << m_serverURL;

    settings.setValue("owncloudcmdVersion", getVersionNumber());

    if (m_username.isEmpty() || m_password.isEmpty() || m_serverURL.isEmpty()){
        qWarning() << "Connection details missing  - Quiting";
        //QCoreApplication::quit();
    }else{

     if(m_syncInterval != 0){
        getSyncFolders();
        //addPathsToWatchlist();
            //if the sync interval is greater than 0
            m_timer = new QTimer(this);
            connect(m_timer, SIGNAL(timeout()), this, SLOT(syncDirs()));
            m_timer->setInterval(m_syncInterval);
            m_timer->start();

            qDebug() << "Sync Frequency: " << QString::number(m_syncInterval / 1000) + " seconds";

            if(!m_folderMap.isEmpty()){
                //Try and sync now.
                syncDirs();
            }
        }else{
            qDebug() << "OwncloudSyncd::OwncloudSyncd - No Sync - Sync interval:" << m_syncInterval;
        }
    }
}

void OwncloudSyncd::emitSignal(QString msgTxt){
    // Example Signal Emit
    QDBusMessage msg = QDBusMessage::createSignal("/org/owncloudsyncd/Controller", "org.owncloudsyncd.Controller", "status");
    msg << msgTxt;
    QDBusConnection::sessionBus().send(msg);
}

QString OwncloudSyncd::getVersionNumber(){

    QString owncloudcmd = getOwncloudCmd();

    QStringList arguments;
    arguments << "--version";

    QProcess *owncloudcmdVersion = new QProcess();
    owncloudcmdVersion->start(owncloudcmd, arguments);
    //Wait for the sync to complete. Dont time out.
    owncloudcmdVersion->waitForFinished(-1);

    QString output(owncloudcmdVersion->readAllStandardOutput());

    if(output.contains("nextcloudcmd version ")){
        output.remove("nextcloudcmd version ");
        output = output.simplified();
    }else{
        output = tr("unspecified");
    }

    return output;
}

QStringList OwncloudSyncd::forceSync(){
    qDebug() << "[owncloudsyncd](OwncloudSyncd::forceSync()) - force a sync event";
    syncDirs();

    QStringList list;
    list << "OwncloudSyncd::forceSync:" << "syncing";

    return list;
}

QStringList OwncloudSyncd::dbusVersionNumber(){
    //return the owncloudcmdversion over dbus.
    QStringList list;
    list << "Version" << getVersionNumber();

    return list;
}

QStringList OwncloudSyncd::dbusStatus(){

    QStringList list;

    if(m_syncing)
    {
        list << "Syncing" << "true";
    }else{
        list << "Syncing" << "false";
    }
    return list;
}

QStringList OwncloudSyncd::getLastSync(){
    QStringList list;

    list << "lastSync" << QString::number(m_lastSync);

    return list;
}

QString OwncloudSyncd::getOwncloudCmd(){

    QString owncloudcmd;

    if( QFile("/opt/click.ubuntu.com/ubsync/current/Owncloud-Sync/lib/arm-linux-gnueabihf/bin/owncloudcmd").exists()){
        owncloudcmd = "/opt/click.ubuntu.com/ubsync/current/Owncloud-Sync/lib/arm-linux-gnueabihf/bin/owncloudcmd";
        qDebug() << "Using Arm owncloudcmd Binary - Mobile";
    }else{
        owncloudcmd = "owncloudcmd";
        qDebug() << "Using Local owncloudcmd Binary - Desktop";
    }

    return owncloudcmd;

}


void OwncloudSyncd::syncDirs(){

    qDebug() << "OwncloudSyncd::syncDirs() - m_syncing = true";
    m_syncing = true;
    emitSignal("SyncStart");

    QMapIterator<QString, QString> i(m_folderMap);
    while (i.hasNext()) {
        i.next();
        if(QDir(i.key()).exists()){
            qDebug() << "Directory: " << i.key() << " - Initiate Sync";
            syncDir(i.key());
        }else{
            qDebug() << "Directory: " << i.key() << " Doesn't exist";
        }
    }
    qDebug() << "OwncloudSyncd::syncDirs() - m_syncing = false";
    m_syncing = false;
    emitSignal("SyncStop");
}

void OwncloudSyncd::addPathsToWatchlist(){

    m_watcher = new QFileSystemWatcher(this);

    QMapIterator<QString, QString> i(m_folderMap);
    while (i.hasNext()) {
        i.next();
        //qDebug() << i.key() << ": " << i.value() << endl;

        if(QDir(i.key()).exists()){
            m_watcher->addPath(i.key());
            //m_watcher->removePath(i.key() + "/.csync_journal.db");
            qDebug() << "/nDirectory: " << i.key() << " Added to watchlist";
        }else{
            qDebug() << "/nDirectory: " << i.key() << " Doesn't exist";
        }
    }

    int dirs = m_watcher->directories().length();

    if(!dirs){
        qDebug() << " No Directories Configured - Quitting";
        return;
        //QCoreApplication::quit();
    }

    qDebug() << QString::number(dirs) << " Directories added to watchlist";
    connect(m_watcher, SIGNAL(directoryChanged(QString)), this, SLOT(syncFolder(QString)));
}

void OwncloudSyncd::loadDB(const QString& path){

    qDebug() << "Attempting to access DB: " << path;

    //QSqlDatabase db = QSqlDatabase::database();
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(path);

    if (!db.open())
    {
        qDebug() << "Error: connection with database fail";
    }else{
        qDebug() << "Database: connection ok";
    }

}

void OwncloudSyncd::getSyncFolders()
{
    //Path should be: //home/phablet/.local/share
    QString path = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);

    path += "/ubsync/Databases";
    qDebug() << "Writeable Path: " << path;

    //Find the Database Name
    QStringList nameFilter("*.sqlite");
    QDir directory(path);
    QStringList dbName = directory.entryList(nameFilter);

    qDebug() << "DB Name: " << dbName.at(0);

    path += "/" + dbName.at(0);

    qDebug() << "Attempting to access DB: " << path;

    //QSqlDatabase db = QSqlDatabase::database();
    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(path);

    //db.open();

    if (!db.open())
    {
        qDebug() << "Error: connection with database fail";
    }else{
        qDebug() << "Database: connection ok";
        qDebug() << "Database Tables:" << db.tables(QSql::AllTables).at(0);

        QSqlQuery query(db);

        query.exec("SELECT local, remote FROM SyncFolders");

        while (query.next()) {
            //qDebug() << query.value(0).toString();
            //qDebug() << query.value(1).toString();
            m_folderMap.insert(query.value(0).toString(), query.value(1).toString());

        }
    }

    db.close();
}

void OwncloudSyncd::syncDir(const QString& localPath){

    qDebug() << "\n"<< endl;

    /*
    QStringList files = watcher->files();

    qDebug() << files.size() << "Files To Check";

    bool filesToSync = false;

    for(int i = 0; i < files.size(); i++){
        qDebug() << "Sync File: " << files.at(i);
        QFileInfo fileInfo(files.at(i));
        if(!fileInfo.isHidden() || fileInfo.isDir()){
            filesToSync = true;
            break;
        }
    }

    if(!filesToSync){
        qDebug() << "Only Hidden Files - Quitting";
        return;
    }
    */

    //m_watcher->blockSignals(true);

    /*
    if (QFile(localPath + "/.csync_journal.db-shm").exists() ||
            QFile(localPath + "/.csync_journal.db-wal").exists()  ){

        qDebug() << "Delete Stale Database File";

        QFile::remove(localPath + "/.csync_journal.db-shm");
        QFile::remove(localPath + "/.csync_journal.db-wal");

    }
    */

    //Create a connection manager, establish is a data connection is avaiable
    QNetworkConfigurationManager mgr;
    qDebug() << "Network Connection Type: " << mgr.defaultConfiguration().bearerTypeName();
    qDebug() << "Mobile Data Sync: " << m_mobileData;

    QList<QNetworkConfiguration> activeConfigs = mgr.allConfigurations(QNetworkConfiguration::Active);
    if (!activeConfigs.count()){
        qWarning() << "No Data Connection Available  - Quiting";
        return;
    }else{
        QNetworkConfiguration::BearerType connType = mgr.defaultConfiguration().bearerType();
        if(!m_mobileData){
            if(connType != QNetworkConfiguration::BearerEthernet && connType != QNetworkConfiguration::BearerWLAN){
                qDebug() << "No Sync on Mobile Data - Check User Settings - Quitting";
                return;
            }
        }

        //Either mobile data sync is allowed or Ethernet or Wifi is available
        //stop m_timer running while syncing
        m_timer->stop();
    }

    QString remotePath = m_serverURL + QStringLiteral("/remote.php/webdav") + m_folderMap.value(localPath);
    qDebug() << "Starting Owncloud Sync from " << localPath << " to " << remotePath;

    QString owncloudcmd = getOwncloudCmd();

    QStringList arguments;
    arguments << "--user" << m_username << "--password" << m_password << "--silent" << "--non-interactive" << localPath << remotePath;

    QProcess *owncloudsync = new QProcess();
    //Retrieve all debug from process
    owncloudsync->setProcessChannelMode(QProcess::ForwardedChannels);
    owncloudsync->start(owncloudcmd, arguments);
    //Wait for the sync to complete. Dont time out.
    owncloudsync->waitForFinished(-1);

    /*
    QDateTime maxWait = QDateTime::currentDateTime();
    maxWait.addSecs(30);
    while (QFile(localPath + "/.csync_journal.db-shm").exists()){

        qDebug() << "Waiting For Sync To Complete: " << QDateTime::currentDateTime();

        if(QDateTime::currentDateTime() > maxWait){
            qDebug() << "maxWait Reached - Quitting Loop";
            break;
        }
    }
    */


    //sleep(10);
    //m_watcher->blockSignals(false);
    //Sync Complete - Save the current date and time
    qDebug() << localPath << " - Sync Completed: " << QDateTime::currentDateTime();

    //start the timer again
    m_timer->start();


    QSettings settings(m_settingsFile, QSettings::IniFormat);
    //QSettings settings(m_settingsFile);
    m_lastSync = QDateTime::currentDateTime().toMSecsSinceEpoch();
    qDebug() << "OwncloudSyncd::getSyncFolders Epoch:" << QDateTime::currentDateTime().toMSecsSinceEpoch() << "m_lastSync:" << m_lastSync;
    settings.setValue("lastSync", m_lastSync);

}
