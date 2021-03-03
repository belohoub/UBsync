#ifndef OWNCLOUDSYNC_H
#define OWNCLOUDSYNC_H

#include <QObject>
#include <QStringList>
#include <QVariant>

class OwncloudSync : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool networkAvailable READ networkAvailable NOTIFY networkAvailableChanged)
public:
    explicit OwncloudSync(QObject *parent = 0);
    Q_INVOKABLE QString homePath();
    Q_INVOKABLE bool newFolder(QString folderPath);
    Q_INVOKABLE QVariantList logPath();
    Q_INVOKABLE void removeAllConfigs();

    bool networkAvailable();


signals:

    void networkAvailableChanged();

public slots:

private:
    void deleteAll(QString path);

};

#endif // OWNCLOUDSYNC_H
