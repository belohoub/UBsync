#ifndef OWNCLOUDSYNCD_H
#define OWNCLOUDSYNCD_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QSettings>
#include <QMap>
#include <QTimer>

#include <QObject>
#include <QDBusAbstractAdaptor>
#include <QDBusArgument>
#include <QPair>

#include <Accounts/Account>
#include <Accounts/Application>
#include <Accounts/Manager>
#include <Accounts/AccountService>

#include <SignOn/AuthSession>
#include <SignOn/Identity>


#define OWNCLOUDSYNCD_SERVICE "org.owncloudsyncd"
#define OWNCLOUDSYNCD_CONTROLLER_PATH "/org/owncloudsyncd/Controller"
#define OWNCLOUDSYNCD_CONTROLLER_INTERFACE "org.owncloudsyncd.Controller"
#define OWNCLOUDSYNCD_VERSION QStringLiteral("0.8")


class OwncloudSyncd : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", OWNCLOUDSYNCD_CONTROLLER_INTERFACE)

public:
    OwncloudSyncd();


    //    ~OwncloudSyncd();

public slots:
    Q_SCRIPTABLE QStringList forceSync();
    Q_SCRIPTABLE QStringList dbusVersionNumber();
    Q_SCRIPTABLE QStringList dbusStatus();
    Q_SCRIPTABLE QStringList dbusDaemonVersion();
    Q_SCRIPTABLE QStringList getLastSync();

signals:
    void syncNow();

private slots:
    void syncDir(const int targetID);
    void syncTargets();
    void signOnResponse(const SignOn::SessionData &sessionData);
    void signOnError(const SignOn::Error &error);
    void getDatabase();
    void getCredentials();

    QString getOwncloudCmd();
    void emitSignal(QString);
    QString getVersionNumber();

private:
    QTimer * m_timer;

    /* last sync invoked */
    qint64 m_lastSync;
    
    /* Config file */
    QString m_settingsFile;
    
    /* minimal sync interval */
    int m_syncInterval;

    /* syncing or not */
    bool m_syncing;

    /* accountID - remoteAddr */
    QMap<int, QString> m_accountAddr;
    /* accountID - remoteUser */
    QMap<int, QString> m_accountUser;
    /* accountID - remotePassword */
    QMap<int, QString> m_accountPass;
    /* accountID - syncHidden */
    QMap<int, bool> m_accountSyncHidden;
    /* accountID - useMobileData */
    QMap<int, bool> m_accountUseMobileData;
    /* accountID - syncFreq */
    QMap<int, int> m_accountSyncFreq;

    /* Account beeing currently processed */
    int m_processedAccountId;

    /* targetID - accountID */
    QMap<int, int> m_targetAccount;
    /* targetID - localPath */
    QMap<int, QString> m_targetLocal;
    /* targetID - remotePath */
    QMap<int, QString> m_targetRemote;
    /* targetID - lastSync */
    QMap<int, qint64> m_targetLastSync;
};

#endif // OWNCLOUDSYNCD_H
