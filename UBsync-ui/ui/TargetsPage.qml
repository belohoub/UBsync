import QtQuick 2.4
import Ubuntu.Components 1.3
import "../components"
import Ubuntu.OnlineAccounts 2.0

import QtQuick.LocalStorage 2.0


Page {
    id: targetsPage

    property var db
    property int debounce: 0

    /* load current data from DB */
    function loadDB() {

        targetListModel.clear();

        targetsPage.db = LocalStorage.openDatabaseSync("UBsync", "1.0", "UBsync", 1000000);

        console.log("TargetsPage :: Loading targetsPage data")

        targetsPage.db.transaction(
                    function(tx) {
                        // load selected target
                        var rs = tx.executeSql('SELECT * FROM SyncTargets');

                        for(var i = 0; i < rs.rows.length; i++) {
                            console.log("TargetsPage :: Loading targetsPage: " + rs.rows.item(i).targetName + "; Active: " + rs.rows.item(i).active)

                            var color = "orange" // expect, that the account is disabled in online accounts
                            var j = 0
                            for (j = 0; j < accounts.count; j++) {
                                //console.log("TargetsPage ::   - accountID: " + accounts.get(j, "account").accountId)
                                if (accounts.get(j, "account").accountId === rs.rows.item(i).accountID) {
                                    // account is enabled!
                                    if (rs.rows.item(i).active === 1) {
                                        // active and target enabled
                                        color = "forestgreen"
                                    } else {
                                        // active and target disabled
                                        color = "silver"
                                    }
                                    break
                                }
                            }

                            targetListModel.append({"targetID": rs.rows.item(i).targetID, "targetName": rs.rows.item(i).targetName, "targeActive": rs.rows.item(i).active, "color": color})
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
            targetName: "Unknown"
            targeActive: false
            color: "silver"
        }

        Component.onCompleted: {
            console.log("TargetsPage :: targetsPage created")

            targetsPage.loadDB()
        }
    }


    header: PageHeader {
        id: header
        title: "UBsync"

        trailingActionBar{
            actions: [
                /* TODO: re-think actions here ? */
                Action {
                    iconName: "settings"
                    onTriggered: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("SyncServicePage.qml"))
                },

                Action {
                    iconName: "account"
                    onTriggered: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("AccountsPage.qml"))
                },

                Action {
                    iconName: "info"
                    onTriggered: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("AboutPage.qml"))
                }
            ]
        }
    }

    Item {
        //Shown only if there are no items in targets
        anchors{centerIn: parent}

        Label{
            visible: !targetListModel.count
            text: i18n.tr("No targets, go to")
            anchors{horizontalCenter: parent.horizontalCenter; bottom: addCenterHelp.top; bottomMargin: units.gu(2)}
        }

        Label {
            id: addCenterHelp
            visible: !targetListModel.count
            text: i18n.tr("Targets Settings")
            width: units.gu(4)
            height: width
            anchors{centerIn: parent}
        }

        Label{
            visible: !targetListModel.count
            text: i18n.tr("and create one ...")
            anchors{horizontalCenter: parent.horizontalCenter; top: addCenterHelp.bottom; topMargin: units.gu(2)}
        }
    }

    ListView {
        id: targetList
        model: targetListModel
        anchors{left:parent.left; right:parent.right; top:header.bottom; bottom:parent.bottom; bottomMargin:units.gu(2)}
        clip: true
        visible: targetListModel.count

        delegate: ListItem {
            height: targetColumn.height
            anchors{left:parent.left; right:parent.right}

            onClicked: {
                apl.addPageToNextColumn(targetsPage, Qt.resolvedUrl("EditTarget.qml"), {targetID: targetID})
            }

            Column {
                id: targetColumn
                height: units.gu(12)

                anchors.leftMargin: units.gu(2)

                spacing: units.gu(1)
                anchors {
                    top: parent.top; left: parent.left; right: parent.right; margins:units.gu(2)
                }

                Rectangle {
                    id: targetIcon
                    color: color
                    width: units.gu(9)
                    height: width
                    border.width: 0
                    radius: 10
                    anchors {
                       left: parent.left; top: parent.top
                    }
                }

                Text {
                    id: targetIconText
                    text: targetName.charAt(0).toUpperCase()
                    color: "white"
                    font.pixelSize: units.gu(6)
                    anchors {
                       horizontalCenter: targetIcon.horizontalCenter; verticalCenter: targetIcon.verticalCenter
                    }
                }

                Text {
                    id: targetName
                    text: targetName
                    height: units.gu(6)
                    font.pixelSize: units.gu(3)
                    anchors.leftMargin: units.gu(2)
                    anchors {
                       left: targetIcon.right; top: parent.top
                    }
                }

                Text {
                    id: targetID
                    text: targetID
                    font.pixelSize: units.gu(2)
                    anchors.leftMargin: units.gu(2)
                    anchors {
                       left: targetIcon.right; top: targetName.bottom
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
                            targetsPage.removeTarget(targetID)
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
                            apl.addPageToNextColumn(targetsPage, Qt.resolvedUrl("EditTarget.qml"), {targetID: targetID})
                        }
                    }
                ]
            }
        }
    }



}
