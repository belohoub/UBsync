#include "daemoncontroller.h"


#include <QDBusConnection>
#include <QDBusInterface>
#include <QDebug>
#include <QDBusPendingReply>

#define OWNCLOUDSYNCD_SERVICE QStringLiteral("org.owncloudsyncd")
#define OWNCLOUDSYNCD_CONTROLLER_PATH QStringLiteral("/org/owncloudsyncd/Controller")
#define OWNCLOUDSYNCD_CONTROLLER_INTERFACE QStringLiteral("org.owncloudsyncd.Controller")

DaemonController::DaemonController(QObject *parent) : QObject(parent)
{

    m_iface = new QDBusInterface(OWNCLOUDSYNCD_SERVICE, OWNCLOUDSYNCD_CONTROLLER_PATH, OWNCLOUDSYNCD_CONTROLLER_INTERFACE, QDBusConnection::sessionBus());
    if (m_iface->isValid()) {

        qDebug() << "[DaemonController::DaemonController] - Connected to owncloudsyncd dbus interface";
    }

    //Example connection to dbus daemon
    QDBusConnection::sessionBus().connect("org.owncloudsyncd", "/org/owncloudsyncd/Controller", "org.owncloudsyncd.Controller", "status", this, SLOT(signalRecieved(QString)));

    //get the daemon status
    m_syncActive = false;
    sendBusCall("dbusStatus");
    getLastSync();
}

void DaemonController::signalRecieved(QString msg){

    qDebug() << "DaemonController::signalRecieved(): " << msg;

    if(msg == "SyncStart")
    {   m_syncActive = true;
        emit syncActiveChanged();
    }

    if(msg == "SyncStop")
    {
        m_syncActive = false;
        getLastSync();
        emit syncActiveChanged();
    }

}

QString DaemonController::lastSync(){

    return m_lastSync;
}

void DaemonController::forceSync(){  
        sendBusCall("forceSync");
}

void DaemonController::getOwncloudcmdVersion(){    
    sendBusCall("dbusVersionNumber");
}

bool DaemonController::syncActive()
{
    sendBusCall("dbusStatus");

    return m_syncActive;
}

void DaemonController::getLastSync()
{
    sendBusCall("getLastSync");
}


void DaemonController::sendBusCall(QString function)
{
    QDBusPendingCall async = m_iface->asyncCall(function);
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(async, this);

    QObject::connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher*)),
                     this, SLOT(callFinishedSlot(QDBusPendingCallWatcher*)));
}

void DaemonController::callFinishedSlot(QDBusPendingCallWatcher *call)
{
    QDBusPendingReply<QStringList> reply = *call;
    if (reply.isError()) {
        qWarning() << "DaemonController::callFinishedSlot:" << reply.error();
    } else {
        //qDebug() << "DaemonController::callFinishedSlot:" << reply.argumentAt<0>(); // << reply.argumentAt<1>();
        handleDbusReply(reply.value());
    }
    call->deleteLater();
}

void DaemonController::handleDbusReply(QStringList list)
{
    qDebug() << "DaemonController::handleDbusReply:" << list;

    if(list.at(0) == "lastSync"){
        m_lastSync = list.at(1);
        //qDebug() << "DaemonController::handleDbusReply - lastSync:" << m_lastSync;
        emit lastSyncChanged();
    }
}
