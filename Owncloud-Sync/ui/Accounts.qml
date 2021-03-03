import QtQuick 2.4
import Ubuntu.Components 1.3

import "../components"

Page {
    id: accountsPage

    header: PageHeader {
        property string username: owncloud.settings.username.charAt(0).toUpperCase() + owncloud.settings.username.slice(1);
        title: username ? i18n.tr("%1's Nextcloud").arg(username) : i18n.tr("Nextcloud")
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
                    onClicked: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("AccountSettingsPage.qml"))
                    ListItemLayout {
                        title.text: i18n.tr("Account Settings")
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
                    onClicked: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("SyncSettingsPage.qml"))
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
            }
        }
    }
}

