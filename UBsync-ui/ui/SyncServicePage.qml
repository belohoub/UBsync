import QtQuick 2.4
import Ubuntu.Components 1.3

import "../components"

Page {
    id: syncServicePage

    header: PageHeader {
        title: i18n.tr("Sync Service")
        flickable: flickable
    }

    Timer {
        //timer updates time since last sync
        interval: 10000;
        running: serviceController.serviceRunning
        repeat: true
        onTriggered: daemonController.getLastSync()
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        flickableDirection: Flickable.AutoFlickIfNeeded

        Column {
            id: dataColumn
            spacing: units.gu(3)
            anchors {
                top: parent.top; left: parent.left; right: parent.right
            }

            Column {
                width: parent.width
                ListItem {
                    ListItemLayout {
                        title.text: i18n.tr("Status: %1").arg(serviceController.serviceRunning ? daemonController.syncActive ? i18n.tr("Syncing") : i18n.tr("Idle") : i18n.tr("Stopped"))
                        anchors{verticalCenter: parent.verticalCenter}


                        Button{
                            text: serviceController.serviceRunning ? i18n.tr("Stop") : i18n.tr("Start")
                            color: serviceController.serviceRunning ? UbuntuColors.red : UbuntuColors.green
                            SlotsLayout.position: SlotsLayout.Trailing;

                            onClicked: {
                                console.log("SyncServicePage :: Accounts.qml - onButtonClicked - Start Sync daemon")
                                connectionStatus.status = serviceController.serviceRunning ? i18n.tr("Stop Service") : i18n.tr("Start Service")
                                connectionStatus.indicationIcon = serviceController.serviceRunning ? "paused" : "updating"
                                serviceController.setServiceRunning(!serviceController.serviceRunning)
                            }
                        }
                    }
                }

                ListItem {
                    ListItemLayout {
                        property string lastSyncTime: daemonController.lastSync ? timeSince(daemonController.lastSync) : owncloud.settings.lastSync ? timeSince(owncloud.settings.lastSync) : i18n.tr("Sync Required")
                        title.text: i18n.tr("Last Sync:")
                        subtitle.text: lastSyncTime
                        anchors{verticalCenter: parent.verticalCenter}

                        Button{
                            text: i18n.tr("Sync")
                            visible: serviceController.serviceRunning && !daemonController.syncActive
                            color: UbuntuColors.green
                            SlotsLayout.position: SlotsLayout.Trailing;

                            onClicked: {
                                console.log("SyncServicePage :: Accounts.qml - onButtonClicked - Start Sync")
                                daemonController.forceSync();
                                connectionStatus.status = i18n.tr("Sync Starting")
                                connectionStatus.indicationIcon = "updating"
                            }
                        }
                    }
                }

                ListItem {
                    //visible: owncloud.settings.owncloudcmdVersion

                    onClicked: daemonController.getOwncloudcmdVersion()

                    ListItemLayout {
                        title.text: i18n.tr("Client : %1").arg(owncloud.settings.owncloudcmdVersion)
                        anchors{verticalCenter: parent.verticalCenter}
                    }
                }
                
                ListItem {
                    //visible: owncloud.settings.owncloudSyncdVersion

                    onClicked: daemonController.getOwncloudSyncdVersion()

                    ListItemLayout {
                        title.text: i18n.tr("Service : %1").arg(owncloud.settings.owncloudSyncdVersion)
                        anchors{verticalCenter: parent.verticalCenter}
                    }
                }
            }
        }
    }



    function timeSince(date) {

        //console.log("SyncServicePage :: SyncServicePage.qml - timeSince() - epoch time:" + date)

        var seconds = Math.floor(new Date().getTime() - date) / 1000;

        var interval = Math.floor(seconds / 31536000);

        if (interval > 1) {
            return i18n.tr("Never");
        }
        interval = Math.floor(seconds / 2592000);
        if (interval > 1) {
            return i18n.tr("%1 Months Ago".arg(interval));
        }
        interval = Math.floor(seconds / 86400);
        if (interval > 1) {
            return i18n.tr("%1 Days Ago".arg(interval));
        }
        interval = Math.floor(seconds / 3600);
        if (interval > 1) {
            return i18n.tr("%1  Hours Ago".arg(interval));
        }
        interval = Math.floor(seconds / 60);
        if (interval > 1) {
            return i18n.tr("%1 Minutes Ago".arg(interval));
        }
        if (seconds > 60 && seconds < 120) {
            return i18n.tr("A Minute Ago");
        }

        if (seconds > 30 && seconds < 60) {
            return i18n.tr("%1 Seconds Ago".arg(Math.floor(seconds)));
        }

        return i18n.tr("Just Now") //Math.floor(seconds) + i18n.tr(" Seconds Ago");
    }



    PopupStatusBox{
        id: connectionStatus
        autoHide: true
        anchors{left: parent.left; right:parent.right; bottom: parent.bottom;}
    }
}
