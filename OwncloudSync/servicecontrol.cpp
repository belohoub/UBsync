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
    QFile f(QDir::homePath() + "/.config/upstart/" + m_serviceName + ".conf");
    return f.exists();
}

bool ServiceControl::installServiceFile()
{
    if (m_serviceName.isEmpty()) {
        qDebug() << "Service name not set. Cannot generate service file.";
        return false;
    }

    QFile f(QDir::homePath() + "/.config/upstart/" + m_serviceName + ".conf");
    if (f.exists()) {
        qDebug() << "Service file already existing...";
        return false;
    }

    if (!f.open(QFile::WriteOnly | QFile::Truncate)) {
        qDebug() << "Cannot create service file";
        return false;
    }

    //QString appDir = qApp->applicationDirPath();
    QString appDir = QDir::currentPath();
    //Mobile Devie =  /opt/click.ubuntu.com/owncloud-sync/0.1
    // Try to replace version with "current" to be more robust against updates
    //appDir.replace(QRegExp("ubsync\/[0-9.]*\/"), "ubsync/current/");

    qDebug() << "App Directory: " << appDir;

    f.write("start on started unity8\n");
    f.write("pre-start script\n");
#if INTPTR_MAX == INT64_MAX
    f.write("   initctl set-env LD_LIBRARY_PATH=/opt/click.ubuntu.com/ubsync/current/lib/aarch64-linux-gnu/\n");
#else
    //f.write("   initctl set-env LD_LIBRARY_PATH=/opt/click.ubuntu.com/ubsync/current/Owncloud-Sync/lib/arm-linux-gnueabihf/lib\n");
    f.write("   initctl set-env LD_LIBRARY_PATH=/opt/click.ubuntu.com/ubsync/current/lib/arm-linux-gnueabihf/\n");
#endif
    f.write("end script\n");

    // This works on desktop
    //f.write("exec " + appDir.toUtf8() + "/" + m_serviceName.toUtf8() + "/" + m_serviceName.toUtf8() + "\n");
    //Mobile
    // Try to replace version with "current" to be more robust against updates
    // Temporary fix for updates
    //f.write("exec " + appDir.toUtf8() + "/lib/arm-linux-gnueabihf/bin/" + m_serviceName.toUtf8() + "\n");
    f.write("exec /opt/click.ubuntu.com/ubsync/current/lib/arm-linux-gnueabihf/bin/" + m_serviceName.toUtf8() + "\n");
    f.close();
    return true;
}

bool ServiceControl::removeServiceFile()
{
    if (m_serviceName.isEmpty()) {
        qDebug() << "Service name not set.";
        return false;
    }
    QFile f(QDir::homePath() + "/.config/upstart/" + m_serviceName + ".conf");
    return f.remove();
}

bool ServiceControl::serviceRunning() const
{

    QProcess p;
    p.start("initctl", {"status", m_serviceName});
    p.waitForFinished();
    QByteArray output = p.readAll();
    //qDebug() << output;
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

bool ServiceControl::startService()
{
    qDebug() << "should start service";

   int ret = QProcess::execute("start", {m_serviceName});
   emit serviceRunningChanged();
   return ret == 0;
}

bool ServiceControl::stopService()
{
    qDebug() << "should stop service";
   int ret = QProcess::execute("stop", {m_serviceName});
   emit serviceRunningChanged();
   return ret == 0;
}

bool ServiceControl::restartService()
{
    qDebug() << "should stop service";
   int ret = QProcess::execute("restart", {m_serviceName});
   emit serviceRunningChanged();
   return ret == 0;
}

