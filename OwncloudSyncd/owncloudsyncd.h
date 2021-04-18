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


//#define OWNCLOUDSYNCD_SERVICE QStringLiteral("org.owncloudsyncd")
//#define OWNCLOUDSYNCD_CONTROLLER_PATH QStringLiteral("/org/owncloudsyncd/Controller")
//#define OWNCLOUDSYNCD_CONTROLLER_INTERFACE QStringLiteral("org.owncloudsyncd.Controller")

#define OWNCLOUDSYNCD_VERSION QStringLiteral("0.6-dev")


class OwncloudSyncd : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.owncloudsyncd.Controller")

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
    void syncDir(const QString& str);
    void syncDirs();

    void loadDB(const QString& path);
    void getSyncFolders();
    void addPathsToWatchlist();

    QString getOwncloudCmd();
    void emitSignal(QString);
    QString getVersionNumber();

private:

    //QFileSystemWatcher watcher;
    QFileSystemWatcher * m_watcher;
    QTimer * m_timer;

    QString m_settingsFile;
    QString m_username;
    QString m_password;
    QString m_serverURL;
    QString m_hidden;
    bool m_mobileData;
    int m_syncInterval;
    qint64 m_lastSync;

    bool m_syncing;


    QMap<QString, QString> m_folderMap;

    //QDateTime m_lastSync;
};

#endif // OWNCLOUDSYNCD_H
