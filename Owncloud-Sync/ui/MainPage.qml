import QtQuick 2.4
import Ubuntu.Components 1.3

import "../components"
import "."

Page {
    id: mainPage

    header: PageHeader {
        property string username: owncloud.settings.username.charAt(0).toUpperCase() + owncloud.settings.username.slice(1);

        title: "UBsync"
        flickable: flickable

        trailingActionBar{
            actions: [
                Action {
                    iconName: "info"
                    onTriggered: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("AboutPage.qml"))
                }
            ]
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent

        Column {
            id: dataColumn

            spacing: units.gu(3)
            anchors {
                top: parent.top; left: parent.left; right: parent.right
            }

            Column {
                width: parent.width

                ListItem {
                    onClicked: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("AccountsPage.qml"))
                    ListItemLayout {
                        title.text: i18n.tr("Accounts Settings")
                        anchors{verticalCenter: parent.verticalCenter}

                        Icon{
                            name: "account"
                            width: units.gu(3)
                            SlotsLayout.position: SlotsLayout.Leading
                        }

                        ProgressionSlot {}
                    }
                }

                ListItem {
                    //onClicked: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("SyncSettingsPage.qml"))
                    onClicked: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("TargetsPage.qml"))
                    ListItemLayout {
                        title.text: i18n.tr("Sync Folders")
                        anchors{verticalCenter: parent.verticalCenter}

                        Icon{
                            name: "document-open"
                            width: units.gu(3)
                            SlotsLayout.position: SlotsLayout.Leading
                        }

                        ProgressionSlot {}
                    }
                }

                ListItem {
                    onClicked: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("SyncServicePage.qml"))
                    ListItemLayout {
                        title.text: i18n.tr("Sync Service")
                        anchors{verticalCenter: parent.verticalCenter}

                        Icon{
                            name: "settings"
                            anchors{verticalCenter: parent.verticalCenter}
                            width: units.gu(3)
                            SlotsLayout.position: SlotsLayout.Leading
                        }

                        ProgressionSlot {}
                    }
                }


                /*ListItem {
                    onClicked: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("EditTarget.qml"), {targetID: 3, accountID: 5})
                    ListItemLayout {
                        title.text: i18n.tr("Test Edit Target")
                        anchors{verticalCenter: parent.verticalCenter}

                        Icon{
                            name: "settings"
                            anchors{verticalCenter: parent.verticalCenter}
                            width: units.gu(3)
                            SlotsLayout.position: SlotsLayout.Leading
                        }

                        ProgressionSlot {}
                    }
                }*/

                ListItem {
                    onClicked: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("AboutPage.qml"))
                    ListItemLayout {
                        title.text: i18n.tr("About UBsync")
                        anchors{verticalCenter: parent.verticalCenter}

                        Icon{
                            name: "info"
                            anchors{verticalCenter: parent.verticalCenter}
                            width: units.gu(3)
                            SlotsLayout.position: SlotsLayout.Leading
                        }

                        ProgressionSlot {}
                    }
                }

                ListItem {
                    ListItemLayout {
                        title.text: i18n.tr("UBsync Online Help")
                        anchors{verticalCenter: parent.verticalCenter}

                        Icon{
                            name: "help"
                            anchors{verticalCenter: parent.verticalCenter}
                            width: units.gu(3)
                            SlotsLayout.position: SlotsLayout.Leading
                        }

                        ProgressionSlot {}
                    }
                }

                
                ListItem {
                    visible: ((!serviceController.serviceRunning) || (!owncloud.settings.owncloudSyncdVersion))
                    ListItemLayout {
                        title.text: i18n.tr("Sync Service Not Running!")
                        anchors{verticalCenter: parent.verticalCenter}

                        Icon{
                            name: "dialog-warning-symbolic"
                            anchors{verticalCenter: parent.verticalCenter}
                            width: units.gu(3)
                            SlotsLayout.position: SlotsLayout.Leading
                        }
                    }
                }
            }
        }
    }
}

