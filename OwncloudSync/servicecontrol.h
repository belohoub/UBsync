#ifndef SERVICECONTROL_H
#define SERVICECONTROL_H

#include <QObject>

class ServiceControl : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString serviceName READ serviceName WRITE setServiceName NOTIFY serviceNameChanged)
    Q_PROPERTY(bool serviceFileInstalled READ serviceFileInstalled NOTIFY serviceFileInstalledChanged)
    Q_PROPERTY(bool serviceRunning READ serviceRunning WRITE setServiceRunning NOTIFY serviceRunningChanged)
    Q_PROPERTY(bool isServiceEnabled READ isServiceEnabled WRITE setServiceEnable NOTIFY serviceEnableChanged)

public:
    explicit ServiceControl(QObject *parent = 0);

    QString serviceName() const;
    void setServiceName(const QString &serviceName);

    bool serviceFileInstalled() const;
    Q_INVOKABLE bool installServiceFile();
    Q_INVOKABLE bool removeServiceFile();

    bool serviceRunning() const;
    Q_INVOKABLE bool setServiceRunning(bool running);
    Q_INVOKABLE bool startService();
    Q_INVOKABLE bool stopService();
    Q_INVOKABLE bool restartService();
    
    bool isServiceEnabled() const;
    Q_INVOKABLE bool setServiceEnable(bool enable);
    Q_INVOKABLE bool enableService();
    Q_INVOKABLE bool disableService();

signals:
    void serviceNameChanged();
    void serviceFileInstalledChanged();
    void serviceRunningChanged();
    void serviceEnableChanged();

private:
    QString m_serviceName;
};

#endif // SERVICECONTROL_H
