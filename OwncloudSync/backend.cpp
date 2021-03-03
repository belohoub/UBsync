#include <QtQml>
#include <QtQml/QQmlContext>
#include <QDebug>
#include "backend.h"
#include "servicecontrol.h"
#include "daemoncontroller.h"
#include "owncloudsync.h"
#include "webdavfolderlistmodel.h"

void BackendPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("OwncloudSync"));

    qmlRegisterType<ServiceControl>(uri, 1, 0, "ServiceController");
    qmlRegisterType<DaemonController>(uri, 1, 0, "DaemonController");
    qmlRegisterType<OwncloudSync>(uri, 1, 0, "OwncloudSync");
    qmlRegisterType<webdavfolderlistmodel>(uri, 1, 0, "WebdavFolderListModel");
}

void BackendPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);

    // This seems to return the wrong path?
    //qDebug() << "backend.cpp - BackendPlugin::initializeEngine - Database storage path: " << engine->offlineStoragePath();

}

