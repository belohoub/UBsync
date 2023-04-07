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
    QCoreApplication::setApplicationName("owncloud-sync");
    QDBusConnection::sessionBus().registerService(OWNCLOUDSYNCD_SERVICE);
    QDBusConnection::sessionBus().registerObject(OWNCLOUDSYNCD_CONTROLLER_PATH, this, QDBusConnection::ExportScriptableSlots|QDBusConnection::ExportScriptableSignals);

    qDebug() << "[owncloudsyncd](OwncloudSyncd::OwncloudSyncd()) - Registering with dbus";


    m_settingsFile =  QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/ubsync/ubsync.conf";

    if( !QFile(m_settingsFile).exists()) {
        qDebug() << "No Settings File - Quiting";
        // QCoreApplication::quit();
    }

    qDebug() << QString("Retrieve settings from ") + m_settingsFile;

    QSettings settings(m_settingsFile, QSettings::IniFormat);

    /* Try to sync every hour */
    m_syncInterval = 3600 * 1000;

    settings.setValue("owncloudcmdVersion", getVersionNumber());
    settings.setValue("owncloudSyncdVersion", OWNCLOUDSYNCD_VERSION);

    m_timer = new QTimer(this);
    connect(m_timer, SIGNAL(timeout()), this, SLOT(syncTargets()));
    m_timer->setInterval(m_syncInterval);
    m_timer->start();

    //Try and sync now.
    syncTargets();

}

void OwncloudSyncd::emitSignal(QString msgTxt){
    // Example Signal Emit
    QDBusMessage msg = QDBusMessage::createSignal(OWNCLOUDSYNCD_CONTROLLER_PATH, OWNCLOUDSYNCD_CONTROLLER_INTERFACE, "status");
    msg << msgTxt;
    QDBusConnection::sessionBus().send(msg);
}


/**
 * @brief Get owncloudcmd version
 *
 * @return version string
 */
QString OwncloudSyncd::getVersionNumber(){

    QString owncloudcmd = getOwncloudCmd();

    QStringList arguments;
    arguments << "--version";

    QProcess *owncloudcmdVersion = new QProcess();
    owncloudcmdVersion->start(owncloudcmd, arguments);
    //Wait for the sync to complete. Dont time out.
    owncloudcmdVersion->waitForFinished(-1);

    QString output(owncloudcmdVersion->readAllStandardOutput());

    if (output.contains("version")) {
        output.resize (26);
        output = output.simplified();
    } else {
        output = tr("unspecified");
    }

    return output;
}

/**
 * @brief force sync NOW
 * @todo force sync now - do not take lastSync into account and sync only selected targets?
 */
QStringList OwncloudSyncd::forceSync(){
    qDebug() << "[owncloudsyncd](OwncloudSyncd::forceSync()) - force a sync event";

    // TODO - change ???
    // set all lastSyncs to 0
    QMapIterator<int, qint64> i(m_targetLastSync);
    while (i.hasNext()) {
        i.next();
        // this will force sync NOW
        m_targetLastSync[i.key()] = 0;
    }

    syncTargets();

    QStringList list;
    list << "OwncloudSyncd::forceSync:" << "syncing";

    return list;
}

/**
 * @brief GET OwncloudSyncd version
 * @return version string through DBUS
 */
QStringList OwncloudSyncd::dbusDaemonVersion(){
    //return the owncloudsyncd version over dbus.
    QStringList list;
    list << "Version" << OWNCLOUDSYNCD_VERSION;

    return list;
}

/**
 * @brief GET owncloudcmd version
 * @return version string through DBUS
 */
QStringList OwncloudSyncd::dbusVersionNumber(){
    //return the owncloudcmdversion over dbus.
    QStringList list;
    list << "Version" << getVersionNumber();

    return list;
}

/**
 * @brief GET OwncloudSyncd status
 * @return status through DBUS
 */
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

/**
 * @brief GET lastSync
 * @return lastSync execution time
 */
QStringList OwncloudSyncd::getLastSync(){
    QStringList list;

    list << "lastSync" << QString::number(m_lastSync);

    return list;
}


/**
 * @brief GET owncloudcmd path
 * @return owncloudcmd PATH
 */
QString OwncloudSyncd::getOwncloudCmd(){

    QString owncloudcmd;

#if INTPTR_MAX == INT64_MAX
    qDebug() << "Arm64";
    if( QFile("/opt/click.ubuntu.com/ubsync/current/lib/aarch64-linux-gnu/bin/owncloudcmd").exists()){
        owncloudcmd = "/opt/click.ubuntu.com/ubsync/current/lib/aarch64-linux-gnu/bin/owncloudcmd";
#else
    qDebug() << "Arm32";
    if( QFile("/opt/click.ubuntu.com/ubsync/current/lib/arm-linux-gnueabihf/bin/owncloudcmd").exists()){
        owncloudcmd = "/opt/click.ubuntu.com/ubsync/current/lib/arm-linux-gnueabihf/bin/owncloudcmd";
#endif
        qDebug() << "Using Arm owncloudcmd Binary - Mobile";
    } else{
        owncloudcmd = "owncloudcmd";
        qDebug() << "Using System owncloudcmd Binary - Desktop";
    }

    return owncloudcmd;

}


/**
 * @brief Accounts reponse
 *
 */
void OwncloudSyncd::signOnResponse(const SignOn::SessionData &sessionData) {
    qDebug() << "Online Accounts response()";

    //qDebug() << "login: " << sessionData.UserName();
    //qDebug() << "password: "  << sessionData.Secret();

    m_accountUser.insert(m_processedAccountId, sessionData.UserName());
    m_accountPass.insert(m_processedAccountId, sessionData.Secret());
}

/**
 * @brief Accounts reponse
 *
 */
void OwncloudSyncd::signOnError(const SignOn::Error &error) {
    qDebug() << "Online Accounts response()";

    m_accountUser.insert(m_processedAccountId, nullptr);
    m_accountPass.insert(m_processedAccountId, nullptr);
}

/**
 * @brief Sync Targets
 *
 */
void OwncloudSyncd::syncTargets() {

    qDebug() << "OwncloudSyncd::syncTargets() - m_syncing = true";

    //stop m_timer running while syncing
    m_timer->stop();

    m_syncing = true;
    m_lastSync = QDateTime::currentDateTime().toMSecsSinceEpoch();

    emitSignal("SyncStart");

    // Get database content ...
    getDatabase();
    // Get current user credentials
    getCredentials();

    QMapIterator<int, int> i(m_targetAccount);
    while (i.hasNext()) {
        i.next();
        if ((m_accountUser[m_targetAccount.value(i.key())]) == nullptr) {
            qDebug() << "Credentials for account ID " << m_targetAccount.value(i.key()) << " NOT available! Skip Sync NOW!";
        } else {
            if (QDir(m_targetLocal[i.key()]).exists()) {
                qDebug() << "Directory: " << m_targetLocal[i.key()] << " - Initiate Sync";
                if (m_targetLastSync.contains(i.key())) {
                    qDebug() << "Directory: " << m_targetLocal[i.key()] << " - Initial Sync; Sync NOW";
                    syncDir(i.key());
                } else if ((QDateTime::currentDateTime().toMSecsSinceEpoch() - m_targetLastSync.value(i.key())) >= m_accountSyncFreq.value(i.key())) {
                    qDebug() << "Directory: " << m_targetLocal[i.key()] << " - Repeated Sync; Sync NOW";
                    qDebug() << "  - m_accountSyncFreq.value(i.key())" << m_accountSyncFreq.value(i.key());
                    qDebug() << "  - m_targetLastSync.value(i.key())" << m_targetLastSync.value(i.key());
                    qDebug() << "  - QDateTime::currentDateTime().toMSecsSinceEpoch()" << QDateTime::currentDateTime().toMSecsSinceEpoch();
                    syncDir(i.key());
                } else {
                    qDebug() << "Directory: " << m_targetLocal[i.key()] << " - Skip Sync NOW";
                }
            } else {
                qDebug() << "Directory: " << m_targetLocal[i.key()] << " Doesn't exist";
            }
        }
    }
    qDebug() << "OwncloudSyncd::syncTargets() - m_syncing = false";

    // todo - start timer with different period?
    m_timer->start();

    m_syncing = false;

    emitSignal("SyncStop");
}


/**
 * @brief GET database content
 *
 */
void OwncloudSyncd::getDatabase()
{
    //Path should be: //home/phablet/.local/share
    QString path = QStandardPaths::writableLocation(QStandardPaths::GenericDataLocation);

    path += "/ubsync/Databases";
    qDebug() << "Writable Path: " << path;

    //Find the Database Name
    QStringList nameFilter("*.sqlite");
    QDir directory(path);
    QStringList dbName = directory.entryList(nameFilter);

    qDebug() << "DB Name: " << dbName.at(0);

    path += "/" + dbName.at(0);

    qDebug() << "Attempting to access DB: " << path;

    QSqlDatabase db = QSqlDatabase::addDatabase("QSQLITE");
    db.setDatabaseName(path);

    if (!db.open()) {
        qDebug() << "Error: connection with database fail";
    } else {
        qDebug() << "Database: connection ok";
        qDebug() << "Database Tables:" << db.tables(QSql::AllTables);

        QSqlQuery query(db);

        query.exec("SELECT accountID, remoteAddress, remoteUser, syncHidden, useMobileData, syncFreq FROM SyncAccounts");

        while (query.next()) {
            m_accountAddr.insert(query.value(0).toInt(), query.value(1).toString());
            //m_accountUser.insert(query.value(0).toInt(), query.value(2).toString()); // this will be obtrained from signond
            m_accountSyncHidden.insert(query.value(0).toInt(), query.value(3).toBool());
            m_accountUseMobileData.insert(query.value(0).toInt(), query.value(4).toBool());
            m_accountSyncFreq.insert(query.value(0).toInt(), query.value(5).toInt());
        }

        query.exec("SELECT targetID, accountID, localPath, remotePath, active FROM SyncTargets");

        while (query.next()) {

            /* if is active */
            if (query.value(4).toBool()) {
                m_targetAccount.insert(query.value(0).toInt(), query.value(1).toInt());
                m_targetLocal.insert(query.value(0).toInt(), query.value(2).toString());
                m_targetRemote.insert(query.value(0).toInt(), query.value(3).toString());
            }
        }
    }

    db.close();
}

/**
 * @brief GET account credentials
 *
 */
void OwncloudSyncd::getCredentials()
{
    Accounts::Manager *manager = new Accounts::Manager();
    Accounts::Account *account;

    /* For response wait */
    QTimer timer;
    QEventLoop loop;

    qDebug() << "getCredentials()";

    QMapIterator<int, QString> i(m_accountAddr);
    while (i.hasNext()) {
        i.next();

        // test if account from the database is enabled
        if (manager->accountListEnabled().contains(i.key()) == false) {
            continue;
        }

        account = manager->account(i.key());
        Accounts::ServiceList services = account->enabledServices();

        foreach (Accounts::Service service, services) {
            qDebug() << "  - Service: " << service.displayName();

            /* Get Credentials */
            Accounts::AccountService * as = new Accounts::AccountService(account, service);
            Accounts::AuthData ad = as->authData();

            QPointer<SignOn::AuthSession> authSession;
            SignOn::IdentityInfo identityInfo;
            identityInfo.setId(ad.credentialsId());
            SignOn::Identity * identity = SignOn::Identity::newIdentity(identityInfo);
            authSession = identity->createSession(ad.method());
            SignOn::SessionData sessionData(ad.parameters());

            connect(authSession, SIGNAL(response(SignOn::SessionData)), SLOT(signOnResponse(SignOn::SessionData)));
            connect(authSession, SIGNAL(error(SignOn::Error)), SLOT(signOnError(SignOn::Error)));

            m_processedAccountId = i.key();

            authSession->request(sessionData, ad.method());

            /* Wait until requested credentials found */
            timer.setSingleShot(true);
            connect(authSession, SIGNAL(response(SignOn::SessionData)), &loop, SLOT(quit()));
            connect(authSession, SIGNAL(error(SignOn::Error)), &loop, SLOT(quit()));
            connect(&timer, SIGNAL(timeout()), &loop, SLOT(quit()));
            timer.start(5000);
            loop.exec(0x00);

            if(timer.isActive()) {
                qDebug() << "Get Credentials for account ID " << i.key() << " SUCCESS!";
            } else {
                qDebug() << "Get Credentials for account ID " << i.key() << " TIMEOUT!";
            }

            disconnect(authSession, SIGNAL(response(SignOn::SessionData)),0,0);
            disconnect(authSession, SIGNAL(error(SignOn::Error)),0,0);
            disconnect(&timer, SIGNAL(timeout()), 0,0);

            // the first service is enough for owncloud/nextcloud
            break;
        }

    }
}



void OwncloudSyncd::syncDir(const int targetID){

    qDebug() << "\n"<< endl << endl;

    //Create a connection manager, establish is a data connection is avaiable
    QNetworkConfigurationManager mgr;
    qDebug() << "Network Connection Type: " << mgr.defaultConfiguration().bearerTypeName();
    qDebug() << "Mobile Data Sync: " << m_accountUseMobileData[m_targetAccount.value(targetID)];

    QList<QNetworkConfiguration> activeConfigs = mgr.allConfigurations(QNetworkConfiguration::Active);
    if (!activeConfigs.count()) {
        qWarning() << "No Data Connection Available  - Unable to Sync";
        return;
    } else {
        QNetworkConfiguration::BearerType connType = mgr.defaultConfiguration().bearerType();
        if( m_accountUseMobileData[m_targetAccount.value(targetID)] == false) {
            if (connType != QNetworkConfiguration::BearerEthernet && connType != QNetworkConfiguration::BearerWLAN) {
                qDebug() << "No Sync on Mobile Data - Check User Settings - Unable to Sync";
                return;
            }
        }
    }

    QString localPath = m_targetLocal[targetID];
    QString remotePath = m_accountAddr[m_targetAccount.value(targetID)] + QStringLiteral("/remote.php/webdav") + m_targetRemote[targetID];
    qDebug() << "Starting Owncloud Sync from " << localPath << " to " << remotePath;

    QString owncloudcmd = getOwncloudCmd();
    QStringList arguments;
    if (m_accountSyncHidden[m_targetAccount.value(targetID)] == true) {
       arguments << "--user" << m_accountUser[m_targetAccount.value(targetID)] << "--password" << m_accountPass[m_targetAccount.value(targetID)] << "--silent" << "--non-interactive" << "-h" << localPath << remotePath;
       qDebug() << "Hidden files synchronisation set";
    } else{
       arguments << "--user" << m_accountUser[m_targetAccount.value(targetID)] << "--password" << m_accountPass[m_targetAccount.value(targetID)] << "--silent" << "--non-interactive" << localPath << remotePath;
    }

    /* The following debug msg contains username/password ! */
    //qDebug() << "Arguments: " << arguments;

    
    QProcess *owncloudsync = new QProcess();
    //Retrieve all debug from process
    owncloudsync->setProcessChannelMode(QProcess::ForwardedChannels);
    owncloudsync->start(owncloudcmd, arguments);
    //Wait for the sync to complete. Dont time out.
    owncloudsync->waitForFinished(-1);
    
    // TODO: Inotify if sync was in media directories
    if (QString::compare(QString(QString(QDir(localPath).absolutePath())).left(QString(QDir("~/Music").absolutePath()).length()), (QString(QDir("~/Music").absolutePath())), Qt::CaseSensitive) == 0) {
        qDebug() << "~/Music subpath synchronized";
    }
    
    if (QString::compare(QString(QString(QDir(localPath).absolutePath())).left(QString(QDir("~/Pictures").absolutePath()).length()), (QString(QDir("~/Pictures").absolutePath())), Qt::CaseSensitive) == 0) {
        qDebug() << "~/Pictures subpath synchronized";
    }
    
    if (QString::compare(QString(QString(QDir(localPath).absolutePath())).left(QString(QDir("~/Videos").absolutePath()).length()), (QString(QDir("~/Videos").absolutePath())), Qt::CaseSensitive) == 0) {
        qDebug() << "~/Videos subpath synchronized";
    }

    // Sync Complete - Save the current date and time
    qDebug() << "Sync of " << localPath << " completed at " << QDateTime::currentDateTime();

    m_targetLastSync[targetID] = QDateTime::currentDateTime().toMSecsSinceEpoch();

}
