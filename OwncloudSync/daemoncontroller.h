#ifndef DAEMONCONTROLLER_H
#define DAEMONCONTROLLER_H

#include <QObject>
#include <QDBusInterface>
#include <QDBusPendingCallWatcher>

class DaemonController : public QObject
{
    Q_OBJECT
    //Q_PROPERTY(QString timeUntilNextSync READ timeUntilSync NOTIFY timeUntilNextSyncChanged)
    Q_PROPERTY(bool syncActive READ syncActive NOTIFY syncActiveChanged)
    Q_PROPERTY(QString lastSync READ lastSync NOTIFY lastSyncChanged)
public:
    explicit DaemonController(QObject *parent = 0);
    Q_INVOKABLE void forceSync();
    Q_INVOKABLE void getOwncloudcmdVersion();
    Q_INVOKABLE void getOwncloudSyncdVersion();
    Q_INVOKABLE void getLastSync();

    bool syncActive();
    QString lastSync();

private slots:
    void callFinishedSlot(QDBusPendingCallWatcher *call);
    void signalRecieved(QString);

signals:
    void syncActiveChanged();
    void lastSyncChanged();

private:
    void sendBusCall(QString function);
    void handleDbusReply(QStringList list);

    QDBusInterface *m_iface;
    QString m_timeUntilNextSync;

    bool m_syncActive;
    QString m_lastSync;
};

#endif // DAEMONCONTROLLER_H
