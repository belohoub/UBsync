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
    QFile fVer(QDir::homePath() + "/.config/upstart/" + m_serviceName + ".version");
    
    return (f.exists() && fVer.exists());
}

bool ServiceControl::installServiceFile()
{
    if (m_serviceName.isEmpty()) {
        qDebug() << "Service name not set. Cannot generate service file.";
        return false;
    }

    QFile f(QDir::homePath() + "/.config/upstart/" + m_serviceName + ".conf");
    // version info file was create to support smooth updates for users with 
    // non-multiarch UBsync version, as paths in the config file changed 
    // and it must be updated when upgarding to multiarch ...
    QFile fVer(QDir::homePath() + "/.config/upstart/" + m_serviceName + ".version");
    
    if (f.exists()) {
        // test if the app is not too old - to handle with v0.5 and older updates
        if (fVer.exists()) {
            qDebug() << "Service file already exist...";
            return false;
        } else {
            qDebug() << "OLD service file exist - updating ... ";
        }
    }

    if (!f.open(QFile::WriteOnly | QFile::Truncate)) {
        qDebug() << "Cannot create service file";
        return false;
    }
    
    if (!fVer.open(QFile::WriteOnly | QFile::Truncate)) {
        qDebug() << "Cannot create version file";
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
    f.write("end script\n");
    f.write("exec /opt/click.ubuntu.com/ubsync/current/lib/aarch64-linux-gnu/bin/" + m_serviceName.toUtf8() + "\n");
#else
    //f.write("   initctl set-env LD_LIBRARY_PATH=/opt/click.ubuntu.com/ubsync/current/Owncloud-Sync/lib/arm-linux-gnueabihf/lib\n");
    f.write("   initctl set-env LD_LIBRARY_PATH=/opt/click.ubuntu.com/ubsync/current/lib/arm-linux-gnueabihf/\n");
    f.write("end script\n");
    f.write("exec /opt/click.ubuntu.com/ubsync/current/lib/arm-linux-gnueabihf/bin/" + m_serviceName.toUtf8() + "\n");
#endif

    f.close();
    
    // Indicate "multiarch" version of this app
    fVer.write("# This is *multiarch* version info only, do not remove this file!\n");
    fVer.close();
    
    return true;
}

bool ServiceControl::removeServiceFile()
{
    if (m_serviceName.isEmpty()) {
        qDebug() << "Service name not set.";
        return false;
    }
    QFile f(QDir::homePath() + "/.config/upstart/" + m_serviceName + ".conf");
    QFile fVer(QDir::homePath() + "/.config/upstart/" + m_serviceName + ".version");
    
    return (f.remove() && fVer.remove());
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

