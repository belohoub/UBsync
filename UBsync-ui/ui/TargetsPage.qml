import QtQuick 2.4
import Lomiri.Components 1.3
import "../components"
import Lomiri.OnlineAccounts 2.0

import QtQuick.LocalStorage 2.0


Page {
    id: targetsPage

    property var db

    // accounts may be not ready ...
    property bool accountsLoaded: false

    /* load current data from DB */
    function loadDB() {

        if (accounts.ready === false) {
            return
        } else {
            accountsLoaded = true
        }

        targetListModel.clear();

        targetsPage.db = LocalStorage.openDatabaseSync("UBsync", "1.0", "UBsync", 1000000);

        console.log("TargetsPage :: Loading targetsPage data")

        targetsPage.db.transaction(
                    function(tx) {
                        // load selected target
                        var rs = tx.executeSql('SELECT * FROM SyncTargets');

                        for(var i = 0; i < rs.rows.length; i++) {
                            console.log("TargetsPage :: Loading targetsPage: " + rs.rows.item(i).targetName + "; Active: " + rs.rows.item(i).active)

                            // test for account configuration
                            var rs2 = tx.executeSql('SELECT * FROM SyncAccounts WHERE accountID = (?)', [rs.rows.item(i).accountID])

                            var color = "silver"
                            var accountColor = "silver"
                            var accountName = i18n.tr("Unknown Account")

                            if (rs2.rows.length === 0)  {
                                color = owncloud.settings.color_targetAccountDisabled // account not configured
                                accountColor = owncloud.settings.color_accountEnabledNotConfigured
                            } else {
                                for (var j = 0; j < rs2.rows.length; j++) {
                                    if (rs2.rows.item(j).accountID === rs.rows.item(i).accountID) {
                                        accountName = rs2.rows.item(j).accountName
                                        break
                                    }
                                }
                                color = owncloud.settings.color_targetAccountDisabled // expect, that the account is disabled in online accounts
                                accountColor = owncloud.settings.color_accountDisabled
                                for (var j = 0; j < accounts.count; j++) {
                                    //console.log("TargetsPage ::   - accountID: " + accounts.get(j, "account").accountId)
                                    if (accounts.get(j, "account").accountId === rs.rows.item(i).accountID) {
                                        // account is enabled!
                                        accountColor = owncloud.settings.color_accountEnabled
                                        if (rs.rows.item(i).active === 1) {
                                            // active and target enabled
                                            color = owncloud.settings.color_targetActive
                                        } else {
                                            // active and target disabled
                                            color = owncloud.settings.color_targetInactive
                                        }
                                        break
                                    }
                                }
                            }

                            targetListModel.append({"targetID": rs.rows.item(i).targetID, "targetName": rs.rows.item(i).targetName, "targeActive": rs.rows.item(i).active, "color": color, "accountColor": accountColor, "accountID": rs.rows.item(i).accountID, "accountName": accountName})
                        }
                    }
                )

        targetList.forceLayout();
    }

    /* remove target */
    function removeTarget(targetID) {

        targetListModel.clear();

        targetsPage.db = LocalStorage.openDatabaseSync("UBsync", "1.0", "UBsync", 1000000);

        console.log("TargetsPage :: Removing target " + targetID)

        targetsPage.db.transaction(
                    function(tx) {
                        // remove target
                        var rs = tx.executeSql('DELETE FROM SyncTargets WHERE targetID = (?)', [targetID]);
                    }
                )

        targetsPage.loadDB();
        targetList.forceLayout();
    }

    AccountModel {
        id: accounts
        applicationId: "ubsync_UBsync"
    }

    Timer {
        // This timer checks if a accounts are ready
        id: continuousCheck
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            // hide back navigation, as this serves as main page in a single-column mode and it is not required in double-column mode
            header.navigationActions[0].visible = false

            // if accounts were not ready update again as soon as possible ...
            if (accountsLoaded === false) {
                targetsPage.loadDB()
                if (accountsLoaded === false) {
                    // if still not ready, wait ...
                    return
                } else {
                    continuousCheck.repeat = false
                }
            }

        }
    }

    Connections {
            target: targetsPage

            onActiveChanged: {
                /* re-render anytime page is shown */
                console.log("TargetsPage :: targetsPage activated")
                targetsPage.loadDB()
            }
        }

    ListModel {
        id: targetListModel

        ListElement {
            targetID: 0
            targetName: "Unknown Target"
            targeActive: 0
            color: "silver"

            accountColor: "silver"
            accountID: 0
            accountName: "Unknown Account"
        }

        Component.onCompleted: {
            console.log("TargetsPage :: targetsPage created")

            targetsPage.loadDB()
        }
    }


    header: PageHeader {
        id: header
        title: i18n.tr("Sync Targets")

        trailingActionBar{
            actions: [
                Action {
                    iconName: "info"
                    text: i18n.tr("About")
                    onTriggered: apl.addPageToNextColumn(targetsPage, Qt.resolvedUrl("AboutPage.qml"))
                },

                Action {
                    iconName: "help"
                    text: i18n.tr("Help")
                    onTriggered: apl.addPageToNextColumn(targetsPage, Qt.resolvedUrl("HelpPage.qml"))
                },

                Action {
                    iconName: "settings"
                    text: i18n.tr("Settings")
                    onTriggered: apl.addPageToNextColumn(targetsPage, Qt.resolvedUrl("SyncServicePage.qml"))
                },

                Action {
                    iconName: "account"
                    text: i18n.tr("Accounts")
                    onTriggered: apl.addPageToNextColumn(targetsPage, Qt.resolvedUrl("AccountsPage.qml"))
                }
            ]

            // Display all icons by default - 4 should be still OK for all possible displays
            numberOfSlots: 4

            /* this page is main page on small display only */
            visible: (apl.columns === 1)
        }
    }

    Item {
        //Shown only if there are no items in targets
        anchors{centerIn: parent}
        width: parent.width - units.gu(4)
        visible: !targetListModel.count

        Label{
            wrapMode: Text.Wrap
            text: i18n.tr("No synchronization targets configured, press")
            anchors{left: parent.left; right: parent.right; bottom: addCenterHelp.top; bottomMargin: units.gu(2)}
            horizontalAlignment: Text.AlignHCenter
        }

        Icon {
            id: addCenterHelp
            name: "account"
            width: units.gu(4)
            height: width
            anchors{centerIn: parent}
        }

        Label{
            wrapMode: Text.Wrap
            text: i18n.tr("in the main panel to enter Account Settings. In Account Settings, create a new synchronization target from an existing or new account. For explanation, see the help page.")
            anchors{ left: parent.left; right: parent.right; top: addCenterHelp.bottom; topMargin: units.gu(2)}
            horizontalAlignment: Text.AlignHCenter
        }
    }

    ListView {
        id: targetList
        model: targetListModel
        anchors{left:parent.left; right:parent.right; top:header.bottom; bottom:parent.bottom; bottomMargin:units.gu(2)}
        clip: true
        visible: targetListModel.count

        onMovementEnded: {
            /* update page when moving ...*/
            targetsPage.loadDB()
        }

        delegate: ListItem {
            height: targetColumn.height
            anchors{left:parent.left; right:parent.right}

            onClicked: {
                apl.addPageToNextColumn(targetsPage, Qt.resolvedUrl("EditTarget.qml"), {targetID: model.targetID})
            }

            Item {
                id: targetColumn
                height: units.gu(12)

                anchors {
                    top: parent.top;
                    left: parent.left;
                    right: parent.right;
                    margins:units.gu(2)
                }

                Rectangle {
                    id: targetIcon
                    color: model.color
                    width: units.gu(9)
                    height: width
                    border.width: 0
                    radius: 10
                    anchors {
                       left: parent.left; top: parent.top
                    }
                }

                Label {
                    id: targetIconText
                    text: model.targetName.charAt(0).toUpperCase()
                    color: "white"
                    font.pixelSize: units.gu(6)
                    anchors {
                       horizontalCenter: targetIcon.horizontalCenter; verticalCenter: targetIcon.verticalCenter
                    }
                }

                Label {
                    id: targetName
                    wrapMode: Text.Wrap
                    maximumLineCount: 2
                    width: parent.width - targetIcon.width - units.gu(4)
                    text: model.targetName
                    height: units.gu(6)
                    font.pixelSize: units.gu(2.5)
                    anchors.leftMargin: units.gu(2)
                    anchors {
                       left: targetIcon.right; top: parent.top
                    }
                }

                /*Label {
                    id: targetID
                    text: model.targetID
                    font.pixelSize: units.gu(2)
                    anchors.leftMargin: units.gu(2)
                    anchors {
                       left: targetIcon.right; top: targetName.bottom
                    }
                }*/

                Rectangle {
                    id: accountSymbol
                    color: model.accountColor
                    width: units.gu(3)
                    height: units.gu(3)
                    border.width: 0
                    radius: units.gu(0.4)
                    anchors {
                        bottom: targetIcon.bottom
                        left: targetIcon.right
                        leftMargin: units.gu(2)
                        bottomMargin: units.gu(0)
                    }
                }

                Label {
                    id: accountSymbolText
                    text: model.accountName.charAt(0).toUpperCase()
                    color: "white"
                    font.pixelSize: units.gu(2)
                    anchors {
                       horizontalCenter: accountSymbol.horizontalCenter; verticalCenter: accountSymbol.verticalCenter
                    }
                }

                Label {
                    id: accountName
                    text: model.accountName
                    wrapMode: Text.Wrap
                    maximumLineCount: 1
                    width: parent.width - targetIcon.width - accountSymbol.width - units.gu(6)
                    anchors.leftMargin: units.gu(1)
                    font.pixelSize: units.gu(2)
                    anchors {
                       left: accountSymbol.right; verticalCenter: accountSymbol.verticalCenter
                    }
                }



                /* TODO display number of sync targets ? */

            }


            leadingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"
                        text: ""
                        onTriggered: {
                            targetsPage.removeTarget(model.targetID)
                        }
                    }
                ]
            }

            trailingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "edit"
                        text: ""
                        onTriggered: {
                            apl.addPageToNextColumn(targetsPage, Qt.resolvedUrl("EditTarget.qml"), {targetID: model.targetID})
                        }
                    }
                ]
            }
        }
    }



}
