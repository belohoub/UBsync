#include "servicecontrol.h"

#include <QFile>
#include <QDir>
#include <QDebug>
#include <QCoreApplication>
#include <QProcess>

ServiceControl::ServiceControl(QObject *parent) : QObject(parent)
{

}

QString ServiceControl::serviceName() const
{
    return m_serviceName;
}

void ServiceControl::setServiceName(const QString &serviceName)
{
    if (m_serviceName != serviceName) {
        m_serviceName = serviceName;
        emit serviceNameChanged();
    }
}

bool ServiceControl::serviceFileInstalled() const
{
    if (m_serviceName.isEmpty()) {
        qDebug() << "Service name not set.";
        return false;
    }
    QFile f(QDir::homePath() + "/.config/systemd/user/" + m_serviceName + ".service");
    
    return (f.exists());
}

bool ServiceControl::installServiceFile()
{
    if (m_serviceName.isEmpty()) {
        qDebug() << "Service name not set. Cannot generate service file.";
        return false;
    }

    QFile f(QDir::homePath() + "/.config/systemd/user/" + m_serviceName + ".service");
    
    if (f.exists()) {
        qDebug() << "Service file already exist...";
    }

    if (!f.open(QFile::WriteOnly | QFile::Truncate)) {
        qDebug() << "Cannot create service file";
        return false;
    }

    f.write("[Unit]\n");
    f.write("Description=UBsync Owncloud/Nextcloud client\n");
    f.write("After=network.target\n");
    f.write("\n");
    f.write("[Service]\n");
    f.write("Type=simple\n");
    f.write("WorkingDirectory=%h/.config/ubsync\n");
#if INTPTR_MAX == INT64_MAX
    f.write("Environment=\"LD_LIBRARY_PATH=/opt/click.ubuntu.com/ubsync/current/lib/aarch64-linux-gnu/\"\n");
    f.write("ExecStart=/opt/click.ubuntu.com/ubsync/current/lib/aarch64-linux-gnu/bin/" + m_serviceName.toUtf8() + "\n");
#else
    f.write("Environment=\"LD_LIBRARY_PATH=/opt/click.ubuntu.com/ubsync/current/lib/arm-linux-gnueabihf/\"\n");
    f.write("ExecStart=/opt/click.ubuntu.com/ubsync/current/lib/arm-linux-gnueabihf/bin/" + m_serviceName.toUtf8() + "\n");
#endif
    f.write("\n");
    f.write("[Install]\n");
    f.write("WantedBy=default.target\n");

    f.close();
    
    int ret = QProcess::execute("systemctl", {"--user", "daemon-reload"});
    if (ret != 0) {
        return false;
    }
    ret = QProcess::execute("systemctl", {"--user", "enable", m_serviceName.toUtf8() + ".service"});
    if (ret != 0) {
        return false;
    }
    
    return true;
}

bool ServiceControl::removeServiceFile()
{
    if (m_serviceName.isEmpty()) {
        qDebug() << "Service name not set.";
        return false;
    }
    QFile f(QDir::homePath() + "/.config/systemd/user/" + m_serviceName + ".service");
    
    return (f.remove());
}

bool ServiceControl::serviceRunning() const
{

    QProcess p;
    p.start("systemctl", {"--user", "status", m_serviceName.toUtf8() + ".service"});
    p.waitForFinished();
    QByteArray output = p.readAllStandardOutput();
    //qDebug() << "Reading service state:" << output;
    return output.contains("running");
}

bool ServiceControl::setServiceRunning(bool running)
{
    qDebug() << "ServiceControl::setServiceRunning:" << running;
    if (running && !serviceRunning()) {
        return startService();
    } else if (!running && serviceRunning()) {
        return stopService();
    }
    return true; // Requested state is already the current state.
}

bool ServiceControl::isServiceEnabled() const
{
    QProcess p;
    p.start("systemctl", {"--user", "status", m_serviceName.toUtf8() + ".service"});
    p.waitForFinished();
    QByteArray output = p.readAllStandardOutput();
    return (!output.contains("disabled;"));
}

bool ServiceControl::enableService()
{
    qDebug() << "should enable service";

    int ret = QProcess::execute("systemctl", {"--user", "enable", m_serviceName.toUtf8() + ".service"});
    emit serviceEnableChanged();
    return (ret == 0);
}

bool ServiceControl::setServiceEnable(bool enable)
{
    qDebug() << "ServiceControl::setServiceEnable:" << enable;
    if (enable && !isServiceEnabled()) {
        return enableService();
    } else if (!enable && isServiceEnabled()) {
        return disableService();
    }
    return true; // Requested state is already the current state.
}

bool ServiceControl::disableService()
{
    qDebug() << "should disable service";

    int ret = QProcess::execute("systemctl", {"--user", "disable", m_serviceName.toUtf8() + ".service"});
    emit serviceEnableChanged();
    return (ret == 0);
}


bool ServiceControl::startService()
{
    qDebug() << "should start service";

    int ret = QProcess::execute("systemctl", {"--user", "start", m_serviceName.toUtf8() + ".service"});
    emit serviceRunningChanged();
    return (ret == 0);
}

bool ServiceControl::stopService()
{
    qDebug() << "should stop service";
    int ret = QProcess::execute("systemctl", {"--user", "stop", m_serviceName.toUtf8() + ".service"});
    emit serviceRunningChanged();
    return (ret == 0);
}

bool ServiceControl::restartService()
{
    qDebug() << "should restart service";
    int ret = QProcess::execute("systemctl", {"--user", "restart", m_serviceName.toUtf8() + ".service"});
    emit serviceRunningChanged();
    return ret == 0;
}
