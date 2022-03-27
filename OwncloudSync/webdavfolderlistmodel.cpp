#include "webdavfolderlistmodel.h"

#include <QDebug>

webdavfolderlistmodel::webdavfolderlistmodel(QObject *parent) : QAbstractListModel(parent)
{
    connect(this, SIGNAL(credentialsChanged()), this, SLOT(setWebdavCredentials()));

    connect(&m_parser, SIGNAL(finished()), this, SLOT(loadFolderList()));
    connect(&m_parser, SIGNAL(errorChanged(QString)), this, SLOT(printError(QString)));
    connect(&m_webdav, SIGNAL(errorChanged(QString)), this, SLOT(printError(QString)));

}

void webdavfolderlistmodel::loadFolderList()
{
    m_folderList = m_parser.getList();

    QMutableListIterator<QWebdavItem> i(m_folderList);
    while (i.hasNext()) {
        QWebdavItem item = i.next();

        if (!m_showFiles){
            if (!item.isDir())
                i.remove();
        }

       if(!m_showDirs){
            if (item.isDir())
                i.remove();
        }
    }

    emit endResetModel();
    emit countChanged();
}

void webdavfolderlistmodel::setWebdavCredentials()
{
    if(!m_username.isNull() && !m_password.isNull() && !m_serverUrl.isNull()){
        qDebug() << "webdavfolderlistmodel::setWebdavCredentials" << "serverUrl:" << m_serverUrl;

        // Target Credentials
        //serverUrl = https://myserver.com/owncloud
        //url = myserver.com
        //path = /owncloud/remote.php/webdav/

        QUrl sUrl(m_serverUrl);

        QString protocol = sUrl.scheme();
        qDebug() << "webdav::setConnectionSettings" << "protocol:" << protocol;

        QString url = sUrl.host();
        qDebug() << "webdav::setConnectionSettings" << "url:" << url;

        int port = sUrl.port();
        if(port == -1) port = 0;
        qDebug() << "webdav::setConnectionSettings" << "port:" << port;

        QString path = sUrl.path();
        path.append("/remote.php/webdav/");
        qDebug() << "webdav::setConnectionSettings" << "path:" << path;

        QWebdav::QWebdavConnectionType connectionType;

        if (protocol == "https")
        {
            connectionType = QWebdav::HTTPS;
        }else{
            connectionType = QWebdav::HTTP;
        }

        //m_webdav.setConnectionSettings(connectionType, url, path, m_username, m_password);
        m_webdav.setConnectionSettings(connectionType, url, path, m_username, m_password, port);
        // qDebug() << "webdav::setConnectionSettings" << "username:" << m_username;
        // qDebug() << "webdav::setConnectionSettings" << "password:" << m_password;
    }
}

QHash<int, QByteArray> webdavfolderlistmodel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[FileNameRole] = "fileName";
    roles[FilePathRole] = "filePath";
    return roles;
}

void webdavfolderlistmodel::getFolderList()
{
    qDebug() << "webdavfolderlistmodel::getFolderList";
    m_parser.listDirectory(&m_webdav, m_path);
}

int webdavfolderlistmodel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return m_folderList.length();
}

QString webdavfolderlistmodel::folder(){

    return m_folder;
}

QString webdavfolderlistmodel::getErrorMsg(){

    return m_errorMsg;
}

void webdavfolderlistmodel::setFolder(QString &folder)
{
    qDebug() << "webdavfolderlistmodel::setFolder - folder changed:" << folder ;
    m_folder = folder;
    //m_webdav.setPath(folder);

    if(!folder.endsWith("/"))
    {
        folder.append("/");
    }
    m_path = folder;

    getFolderList();

    emit folderChanged();
}

void webdavfolderlistmodel::newWebDavFolder(QString folderPath)
{
    m_webdav.mkdir(folderPath);
    getFolderList();

    emit folderChanged();
}

void webdavfolderlistmodel::setUsername(QString &username)
{
    m_username = username;
    emit credentialsChanged();
}

void webdavfolderlistmodel::setPassword(QString &password)
{
    m_password = password;
    emit credentialsChanged();
}

void webdavfolderlistmodel::setServerUrl(QString &serverUrl)
{
    m_serverUrl = serverUrl;
    emit credentialsChanged();
}

bool webdavfolderlistmodel::showDirs()
{
    return m_showDirs;
}

void webdavfolderlistmodel::setShowDirs(bool &showDirs)
{
    m_showDirs = showDirs;
}

bool webdavfolderlistmodel::showFiles()
{
    return m_showFiles;
}

void webdavfolderlistmodel::setShowFiles(bool &showFiles)
{
    m_showFiles = showFiles;
}

bool webdavfolderlistmodel::showHidden()
{
    return m_showHidden;
}

void webdavfolderlistmodel::setShowHidden(bool &showHidden)
{
    m_showHidden = showHidden;
}

QVariant webdavfolderlistmodel::data(const QModelIndex &index, int role) const
{
    QVariant modeldata;
    if (role == FileNameRole)
    {
        modeldata = getName(index.row());
    }
    else if (role == FilePathRole)
    {
        modeldata = getPath(index.row());
    }

    return modeldata;
}

QString webdavfolderlistmodel::getName(int index) const
{
    return m_folderList.at(index).name();
}

QString webdavfolderlistmodel::getPath(int index) const
{
    return m_folderList.at(index).path();
}

bool webdavfolderlistmodel::isFolder(int index) const
{
    if (index != -1) {
        return m_folderList.at(index).isDir();
    }
    return false;
}

void webdavfolderlistmodel::printError(QString errorMsg)
{
    qDebug() << "webdavfolderlistmodel::printErrors()  errorMsg == " << errorMsg;

    m_errorMsg = errorMsg;

    emit errorOccured();
}

void webdavfolderlistmodel::replySkipRead()
{
    QNetworkReply* reply = qobject_cast<QNetworkReply*>(QObject::sender());
    if (reply==0)
        return;

    QByteArray ba = reply->readAll();

    qDebug() << "webdavfolderlistmodel::replySkipRead()   skipped " << ba.size() << " reply->url() == " << reply->url().toString(QUrl::RemoveUserInfo);
}
