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

#include <Accounts/Account>
#include <Accounts/Application>
#include <Accounts/Manager>
#include <Accounts/AccountService>

#include <QtDBus/QtDBus>

#include <SignOn/AuthSession>
#include <SignOn/Identity>

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

    /*m_username = settings.value("username").toString();
    m_password = settings.value("password").toString();
    m_serverURL = settings.value("serverURL").toString();
    m_mobileData = settings.value("mobileData").toBool();
    m_hidden = settings.value("hiddenfiles").toString();
    m_syncInterval = settings.value("timer").toInt() * 3600 * 1000 ;
    m_lastSync = settings.value("lastSync").toInt();*/

    /* Try to sync every hour */
    m_syncInterval = 3600 * 1000;

    settings.setValue("owncloudcmdVersion", getVersionNumber());
    settings.setValue("owncloudSyncdVersion", OWNCLOUDSYNCD_VERSION);

    m_timer = new QTimer(this);
    connect(m_timer, SIGNAL(timeout()), this, SLOT(syncTargets()));
    m_timer->setInterval(m_syncInterval);
    m_timer->start();


/*
    // Instantiate an account manager interested in e-mail services only.
    Accounts::Manager *manager = new Accounts::Manager();
    // Get the list of enabled AccountService objects of type e-mail.
    Accounts::ServiceList services = manager->serviceList("");
    // Loop through the account services and do something useful with them.
    qDebug() << "XXX: ";
    foreach (Accounts::Service service, services) {
        qDebug() << "  - SSS: " << service.displayName();
    }
    qDebug() << "XXX: ";*/


    /*
    // Instantiate an account manager interested in e-mail services only.
    Accounts::Manager *manager = new Accounts::Manager();
    // Get the list of enabled AccountService objects of type e-mail.
    Accounts::ServiceList services = manager->serviceList();
    Accounts::AccountIdList accounts = manager->accountListEnabled();
    // Loop through the account services and do something useful with them.
    qDebug() << "XXX: ";
    foreach (Accounts::AccountId accountID, accounts) {
        Accounts::Account * account = manager->account(accountID);
        foreach (Accounts::Service service, services) {
            qDebug() << "  - Service: " << service.displayName();
            qDebug() << "  - Account: " << account->displayName();
        }
    }
    qDebug() << "XXX: ";*/

    // Instantiate an account manager interested in e-mail services only.
    Accounts::Manager *manager = new Accounts::Manager();
    // Get the list of enabled AccountService objects of type e-mail.
    //Accounts::ServiceList services = manager->serviceList();
    //Accounts::AccountIdList accounts = manager->accountListEnabled();
    // Loop through the account services and do something useful with them.
    qDebug() << "XXX: ";
    Accounts::Account * account = manager->account(1);
    qDebug() << "  - Account: " << account->displayName();
    qDebug() << "  - Keys: " << account->allKeys();
    qDebug() << "  - Host: " << account->value("host");
    qDebug() << "  - CredentialsId: " << account->value("CredentialsId");
    qDebug() << "  - enabled: " << account->value("enabled");
    qDebug() << "  - name: " << account->value("name");
    qDebug() << "  - auth/method: " << account->value("auth/method");
    qDebug() << "  - auth/mechanism: " << account->value("auth/mechanism");
    qDebug() << "  - ChildKeys: " << account->childKeys();

    Accounts::ServiceList services =  account->enabledServices();
    foreach (Accounts::Service service, services) {
        qDebug() << "  - Service: " << service.displayName();
        if (QString::compare(service.displayName(), "Owncloud", Qt::CaseInsensitive)) {
            qDebug() << "    -> owncloud ";
            Accounts::AccountService * as = new Accounts::AccountService(account, service);
            Accounts::AuthData ad = as->authData();
            qDebug() << "    -> authData " << ad.parameters().keys();

            /*
            //QPointer<SignOn::AuthSession> authSession;
            SignOn::IdentityInfo * identityInfo = new SignOn::IdentityInfo();
            identityInfo->setId(ad.credentialsId());
            SignOn::Identity identity = SignOn::Identity::newIdentity(identityInfo, this);
            //authSession = identity->createSession(ad.method());
            //authSession->process(ad.parameters(), ad.mechanism());
*/
            qDebug() << "    -> Tags: " << service.tags();

            qDebug() << "    ->DOM: " << service.domDocument().toString();

        } else if (QString::compare(service.displayName(), "Nextcloud", Qt::CaseInsensitive)) {
            qDebug() << "    -> nextcloud ";
        }
    }


    account = manager->account(5);
    qDebug() << "  - Account: " << account->displayName();
    qDebug() << "  - Keys: " << account->allKeys();
    qDebug() << "ID:: " << account->credentialsId();

    qDebug() << "XXX: ";



    //Try and sync now.
    syncTargets();

}

void OwncloudSyncd::emitSignal(QString msgTxt){
    // Example Signal Emit
    QDBusMessage msg = QDBusMessage::createSignal("/org/owncloudsyncd/Controller", "org.owncloudsyncd.Controller", "status");
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

    // todo ???
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

    QMapIterator<int, int> i(m_targetAccount);
    while (i.hasNext()) {
        i.next();
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
            m_accountUser.insert(query.value(0).toInt(), query.value(2).toString());
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

    qDebug() << "Arguments: " << arguments;

    qDebug() << "Accounts: ";


 //   QProcess *owncloudsync = new QProcess();
    //Retrieve all debug from process
 //   owncloudsync->setProcessChannelMode(QProcess::ForwardedChannels);
 //   owncloudsync->start(owncloudcmd, arguments);
 //   //Wait for the sync to complete. Dont time out.
 //   owncloudsync->waitForFinished(-1);

    // Sync Complete - Save the current date and time
    qDebug() << "Sync of " << localPath << " completed at " << QDateTime::currentDateTime();

    m_targetLastSync[targetID] = QDateTime::currentDateTime().toMSecsSinceEpoch();

}
