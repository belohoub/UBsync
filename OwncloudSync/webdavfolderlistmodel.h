#ifndef WEBDAVFOLDERLISTMODEL_H
#define WEBDAVFOLDERLISTMODEL_H

#include <QObject>
#include <QAbstractListModel>

//#include "webdav.h"

//webdav stuff
#include <qwebdav.h>
#include <qwebdavdirparser.h>
#include <qwebdavitem.h>



class webdavfolderlistmodel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QString errorMsg READ getErrorMsg NOTIFY errorOccured)
    Q_PROPERTY(QString folder READ folder WRITE setFolder NOTIFY folderChanged)
    Q_PROPERTY(bool showDirs READ showDirs WRITE setShowDirs)
    Q_PROPERTY(bool showFiles READ showFiles WRITE setShowFiles)
    Q_PROPERTY(bool showHidden READ showHidden WRITE setShowHidden)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString username WRITE setUsername NOTIFY credentialsChanged)
    Q_PROPERTY(QString password WRITE setPassword  NOTIFY credentialsChanged)
    Q_PROPERTY(QString serverUrl WRITE setServerUrl NOTIFY credentialsChanged)

public:
    explicit webdavfolderlistmodel (QObject *parent = 0);

    enum Roles { FileNameRole = Qt::UserRole+1,
                 FilePathRole = Qt::UserRole+2
               };

    QHash<int, QByteArray> roleNames() const;

    int rowCount(const QModelIndex &parent) const;
    QVariant data(const QModelIndex &index, int role) const;

    int count() const { return rowCount(QModelIndex()); }

    QString getErrorMsg();

    QString folder();    
    void setFolder(QString &folder);

    void setUsername(QString &username);
    void setPassword(QString &password);
    void setServerUrl(QString &serverUrl);

    bool showDirs();
    void setShowDirs(bool &showDirs);

    bool showFiles();
    void setShowFiles(bool &showFiles);

    bool showHidden();
    void setShowHidden(bool &showHidden);

    Q_INVOKABLE bool isFolder(int index) const;
    Q_INVOKABLE void newWebDavFolder(QString folderPath);

    QString getName(int index) const;
    QString getPath(int index) const;

signals:
    void folderChanged();
    void countChanged();
    void credentialsChanged();
    void errorOccured();

public slots:
    Q_INVOKABLE void getFolderList();

//webdav stuff
//public slots:
    void loadFolderList();
    void printError(QString errorMsg);
    void replySkipRead();

private slots:
    //void modelDataChanged();
    void setWebdavCredentials();

private:
    QString m_folder;
    QString m_errorMsg;
    QString m_username;
    QString m_password;
    QString m_serverUrl;
    bool m_showDirs;
    bool m_showFiles;
    bool m_showHidden;

    //webdav stuff
    QWebdav m_webdav;
    QWebdavDirParser m_parser;
    QString m_path;
    QList<QNetworkReply *> m_replyList;
    QList<QWebdavItem> m_folderList;
};

#endif // WEBDAVFOLDERLISTMODEL_H
