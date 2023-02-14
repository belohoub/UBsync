import QtQuick 2.4
import Lomiri.Components 1.3


Page {
    id: menuPage

    property int delayedExec: 1

    // An instance of the alternative mainPage
    TargetsPage {
       id: targetsPage
    }

    header: PageHeader {
        id: header
        title: i18n.tr("UBsync")
        flickable: flickable

        trailingActionBar{
            actions: [

            ]
        }
    }

    Timer {
        id: checkLayoutTimer
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            if (delayedExec > 0) {
                delayedExec = delayedExec - 1
            } else {
                console.log("MenuPage :: adding targetsPage")
                apl.addPageToNextColumn(menuPage, targetsPage)
                checkLayoutTimer.repeat = false
            }

        }
    }

    Flickable {
        id: flickable

        flickableDirection: Flickable.AutoFlickIfNeeded
        anchors.fill: parent
        contentHeight: targetList.height

            Grid {
                id: targetList
                visible: true

                width: parent.width
                anchors {
                    top: parent.top; left: parent.left; right: parent.right; topMargin: units.gu(1); rightMargin:units.gu(1); leftMargin: units.gu(1)
                }

                height: units.gu(8) * 6 + units.gu(2)


                ListItem {
                    id: target
                    height: units.gu(8)
                    width: parent.width

                    anchors {
                        top: parent.top;
                        left: parent.left;
                        right: parent.right;
                    }

                    onClicked: {
                        apl.addPageToNextColumn(menuPage, targetsPage)
                    }

                    Icon {
                        id: targetIcon
                        name: "folder-symbolic"
                        width: units.gu(6)
                        height: width
                        anchors {
                           left: parent.left; top: parent.top
                           margins: units.gu(1)
                        }
                        }

                    Label {
                        id: targetLink
                        text: i18n.tr("Sync Targets")
                        font.pixelSize: units.gu(2)
                        width: text.width
                        anchors {
                             left: targetIcon.right
                             verticalCenter: targetIcon.verticalCenter;
                             leftMargin: units.gu(2)
                        }
                    }

                    Icon {
                        id: targetNextIcon
                        name: "go-next"
                        height: units.gu(4)
                        anchors {
                            verticalCenter: targetIcon.verticalCenter
                            right: parent.right
                            rightMargin: units.gu(1)
                        }
                    }
                }

                ListItem {
                    id: accounts
                    height: units.gu(8)

                    anchors {
                        top: target.bottom;
                        left: parent.left;
                        right: parent.right;
                    }

                    onClicked: {
                        apl.addPageToNextColumn(targetsPage, Qt.resolvedUrl("AccountsPage.qml"))
                    }

                    Icon {
                        id: accountIcon
                        name: "account"
                        width: units.gu(6)
                        height: width
                        anchors {
                           left: parent.left; top: parent.top
                           margins: units.gu(1)
                        }
                        }

                    Label {
                        id: accountLink
                        text: i18n.tr("Online Accounts")
                        font.pixelSize: units.gu(2)
                        width: text.width
                        anchors {
                             left: accountIcon.right
                             verticalCenter: accountIcon.verticalCenter;
                             leftMargin: units.gu(2)
                        }
                    }

                    Icon {
                        id: accountNextIcon
                        name: "go-next"
                        height: units.gu(4)
                        anchors {
                            verticalCenter: accountIcon.verticalCenter
                            right: parent.right
                            rightMargin: units.gu(1)
                        }
                    }
                }

                ListItem {
                    id: settings
                    height: units.gu(8)

                    anchors {
                        top: accounts.bottom;
                        left: parent.left;
                        right: parent.right;
                    }

                    onClicked: {
                        apl.addPageToNextColumn(targetsPage, Qt.resolvedUrl("SyncServicePage.qml"))
                    }

                    Icon {
                        id: settingsIcon
                        name: "settings"
                        width: units.gu(6)
                        height: width
                        anchors {
                           left: parent.left; top: parent.top
                           margins: units.gu(1)
                        }
                        }

                    Label {
                        id: settingsLink
                        text: i18n.tr("Settings")
                        font.pixelSize: units.gu(2)
                        width: text.width
                        anchors {
                             left: settingsIcon.right
                             verticalCenter: settingsIcon.verticalCenter;
                             leftMargin: units.gu(2)
                        }
                    }

                    Icon {
                        id: settingsNextIcon
                        name: "go-next"
                        height: units.gu(4)
                        anchors {
                            verticalCenter: settingsIcon.verticalCenter
                            right: parent.right
                            rightMargin: units.gu(1)
                        }
                    }
                }

                ListItem {
                    id: help
                    height: units.gu(8)

                    anchors {
                        top: settings.bottom;
                        left: parent.left;
                        right: parent.right;
                    }

                    onClicked: {
                        apl.addPageToNextColumn(targetsPage, Qt.resolvedUrl("HelpPage.qml"))
                    }

                    Icon {
                        id: helpIcon
                        name: "help"
                        width: units.gu(6)
                        height: width
                        anchors {
                           left: parent.left; top: parent.top
                           margins: units.gu(1)
                        }
                        }

                    Label {
                        id: helpLink
                        text: i18n.tr("Help")
                        font.pixelSize: units.gu(2)
                        width: text.width
                        anchors {
                             left: helpIcon.right
                             verticalCenter: helpIcon.verticalCenter;
                             leftMargin: units.gu(2)
                        }
                    }

                    Icon {
                        id: helpNextIcon
                        name: "go-next"
                        height: units.gu(4)
                        anchors {
                            verticalCenter: helpIcon.verticalCenter
                            right: parent.right
                            rightMargin: units.gu(1)
                        }
                    }
                }


                ListItem {
                    id: about
                    height: units.gu(8)

                    anchors {
                        top: help.bottom;
                        left: parent.left;
                        right: parent.right;
                    }

                    onClicked: {
                        apl.addPageToNextColumn(targetsPage, Qt.resolvedUrl("AboutPage.qml"))
                    }

                    Icon {
                        id: aboutIcon
                        name: "info"
                        width: units.gu(6)
                        height: width
                        anchors {
                           left: parent.left; top: parent.top
                           margins: units.gu(1)
                        }
                        }

                    Label {
                        id: aboutLink
                        text: i18n.tr("About")
                        font.pixelSize: units.gu(2)
                        width: text.width
                        anchors {
                             left: aboutIcon.right
                             verticalCenter: aboutIcon.verticalCenter;
                             leftMargin: units.gu(2)
                        }
                    }

                    Icon {
                        id: aboutNextIcon
                        name: "go-next"
                        height: units.gu(4)
                        anchors {
                            verticalCenter: aboutIcon.verticalCenter
                            right: parent.right
                            rightMargin: units.gu(1)
                        }
                    }
                }


            }

    }



}

