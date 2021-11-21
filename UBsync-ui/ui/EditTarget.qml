import QtQuick 2.4
import Ubuntu.Components 1.3

import Ubuntu.OnlineAccounts 2.0

import QtQuick.LocalStorage 2.0


Page {
    id: targetPage

    property var db

    /* Pass paramters */
    property int targetID: 0

    /* Required when creating a new record */
    property int accountID: 0

    /* Other parameters */
    property string accountUser: ""
    property string accountPassword: ""
    property string accountRemoteAddress: ""

    /* Account status */
    property bool accountEnabled: false
    property bool accountConfigured: false

    // accounts may be not ready ...
    property bool accountsLoaded: false


    function updateSymbolColors() {
        if (accountEnabled === false) {
            targetSymbol.color = owncloud.settings.color_targetAccountDisabled
            accountSymbol.color = owncloud.settings.color_accountDisabled
        } else if (accountConfigured === false) {
            accountName.text = i18n.tr("Not Configured Account") + "\n(" + i18n.tr("related targets will NOT sync") + ")"
            targetSymbol.color = owncloud.settings.color_targetAccountDisabled
            accountSymbol.color = owncloud.settings.color_accountEnabledNotConfigured
        } else if (activeSwitch.checked === false) {
            targetSymbol.color = owncloud.settings.color_targetInactive
            accountSymbol.color = owncloud.settings.color_accountEnabled
        } else {
            targetSymbol.color = owncloud.settings.color_targetActive
            accountSymbol.color = owncloud.settings.color_accountEnabled
        }
    }


    function loadDB() {

        if (accounts.ready === false) {
            return
        } else {
            accountsLoaded = true
        }

        targetPage.db = LocalStorage.openDatabaseSync("UBsync", "1.0", "UBsync", 1000000);

        console.log("EditTarget :: Loading SyncTargets ID " + targetPage.targetID)

        targetPage.db.transaction(
                    function(tx) {
                        // Create table if it doesn't already exist
                        tx.executeSql('CREATE TABLE IF NOT EXISTS SyncTargets(targetID INTEGER PRIMARY KEY AUTOINCREMENT, accountID INTEGER, localPath TEXT, remotePath TEXT, targetName TEXT, active BOOLEAN)');

                        // load selected target
                        var rs = tx.executeSql('SELECT * FROM SyncTargets WHERE targetID = (?)', targetPage.targetID);

                        for(var i = 0; i < rs.rows.length; i++) {
                            targetPage.accountID =  rs.rows.item(i).accountID

                            targetName.text = rs.rows.item(i).targetName

                            localPath.text = rs.rows.item(i).localPath
                            remotePath.text = rs.rows.item(i).remotePath

                            console.log("EditTarget :: Target Enabled: " + rs.rows.item(i).active)
                            activeSwitch.checked = rs.rows.item(i).active
                        }
                    }
                    )

        targetPage.db.transaction(
                    function(tx) {
                        // load selected target
                        var rs = tx.executeSql('SELECT * FROM SyncAccounts WHERE accountID = (?)', targetPage.accountID);

                        if (rs.rows.length === 0) {
                            accountConfigured = false
                        } else {
                            accountConfigured = true
                            for(var i = 0; i < rs.rows.length; i++) {
                               accountName.text = rs.rows.item(i).accountName

                               targetPage.accountUser = rs.rows.item(i).remoteUser
                               targetPage.accountRemoteAddress = rs.rows.item(i).remoteAddress
                            }
                        }
                    }
                    )

        // test if account is enabled in online accounts
        targetPage.accountEnabled = false
        for (var j = 0; j < accounts.count; j++) {
            if (accounts.get(j, "account").accountId ===  targetPage.accountID) {
                // account is enabled!
                targetPage.accountEnabled = true
                break
            }
        }

        updateSymbolColors()
    }

    function updateDB() {
        targetPage.db.transaction(
                    function(tx) {

                        var rs = tx.executeSql('SELECT * FROM SyncTargets WHERE targetID = (?)', targetPage.targetID);

                        if (rs.rows.length === 0) {
                            console.log("EditTarget :: Inserting SyncTargets ID " + targetPage.targetID)
                            tx.executeSql('INSERT INTO SyncTargets VALUES(NULL, (?), (?), (?), (?), 1)', [
                                              targetPage.accountID,
                                              localPath.text,
                                              remotePath.text,
                                              targetName.text]);

                            // load inserted ID
                            rs = tx.executeSql('SELECT * FROM SyncTargets');
                            targetPage.targetID = rs.rows.item(rs.rows.length - 1).targetID

                            targetIDText.text = "ID: " + targetPage.targetID

                        } else {
                            console.log("EditTarget :: Updating SyncTargets ID " + targetPage.targetID)
                            tx.executeSql('UPDATE SyncTargets SET accountID=(?), localPath=(?), remotePath=(?), targetName=(?), active=(?) WHERE targetID = (?)', [
                                              targetPage.accountID,
                                              localPath.text,
                                              remotePath.text,
                                              targetName.text,
                                              activeSwitch.checked,
                                              targetPage.targetID]);
                        }
                    }
                    )
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
            // if accounts were not ready update again as soon as possible ...
            if (accountsLoaded === false) {
                targetPage.loadDB()
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
          id: accountConnection
          target: null

          onAuthenticationReply: {
              var reply = authenticationData

              if ("errorCode" in reply) {
                  console.warn("Authentication error: " + reply.errorText + " (" + reply.errorCode + ")")
                  // TODO: report an error to user ?

              } else {
                  targetPage.accountUser = reply.Username
                  targetPage.accountPassword = reply.Password
                  /* TODO: activate in debug mode? */
                  //console.log("EditTarget :: Account details are: " + reply.Username + ":" + reply.Password )
              }

          }
    }

    Connections {
            target: targetPage

            onActiveChanged: {
                /* re-render anytime page is shown */
                console.log("EditTarget :: editTargetPage activated")
                targetPage.loadDB()
                targetPage.updateDB() // initial saving of the new target

                console.log("EditTarget :: Authenticate accountID: " + targetPage.accountID)
                console.log("EditTarget ::   - account CNT: " + accounts.count)

                for (var j = 0; j < accounts.count; j++) {
                    //console.log("EditTarget ::   - accountID: " + accounts.get(j, "account").accountId)
                    if (accounts.get(j, "account").accountId === targetPage.accountID) {
                        console.log("EditTarget :: Account auth to get password ... ")
                        accountConnection.target = accounts.get(j, "account")
                        accounts.get(j, "account").authenticate({})
                    }
                }

            }
        }


    header: PageHeader {
        id: header
        title: i18n.tr("Target Settings")
        flickable: flickable

        trailingActionBar{
            actions: [

            ]
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: accountEditColumn.height

        Column {
            id: accountEditColumn

            spacing: units.gu(1.5)
            anchors {
                top: parent.top; left: parent.left; right: parent.right; margins: units.gu(2)
            }

            Item {
                width: parent.width
                height: targetSymbol.height
                anchors.topMargin: units.gu(10)

            Rectangle {
                id: targetSymbol
                color: "silver" /*"#0000B5"*/
                width: units.gu(15)
                height: units.gu(15)
                border.width: 0
                radius: units.gu(2)
                anchors {
                   left: parent.left; top: parent.top
                }
            }

            Text {
                id: targetSymbolText
                text: "U"  /* Modified by Name change */
                color: "white"
                font.pixelSize: units.gu(10)
                anchors {
                   horizontalCenter: targetSymbol.horizontalCenter; verticalCenter: targetSymbol.verticalCenter
                }
            }


            TextEdit {
                id: targetName
                text: "New Target"
                anchors.leftMargin: units.gu(2)
                font.pixelSize: units.gu(3)
                anchors {
                   left: targetSymbol.right; top: targetSymbol.top
                }
                readOnly: true
            }

            Item {
                width: targetNameEditIcon.width
                height: targetNameEditIcon.height
                anchors {
                   right: parent.right; top: targetSymbol.top
                }

                MouseArea {
                    width: targetNameEditIcon.width
                    height: targetNameEditIcon.height

                    onClicked: {
                        /* Init name editing */
                        if (targetName.readOnly === true) {
                            targetName.readOnly = false;
                            //targetName.selectAll()
                            targetName.forceActiveFocus()
                            targetName.cursorVisible = true
                            targetNameEditIcon.name = "ok"
                            targetName.cursorPosition = 0
                            console.log("EditTarget :: Change Name Start")
                        } else {
                            targetName.readOnly = true;
                            //targetName.deselect()
                            targetNameEditIcon.name = "edit"
                            console.log("EditTarget :: Change Name Finished: " + targetName.text)
                            targetSymbolText.text = "" + targetName.text.charAt(0).toUpperCase()
                            targetPage.updateDB()
                            targetPage.loadDB()
                        }
                    }
                }
                Icon {
                    id: targetNameEditIcon
                    name: "edit"
                    width: units.gu(4)
                    height: width
                }
            }

            Text {
                id: targetIDText
                text: "ID: " + targetPage.targetID
                anchors.leftMargin: units.gu(2)
                anchors.topMargin: units.gu(1)
                font.pixelSize: units.gu(3)
                anchors {
                   left: targetSymbol.right; top: targetName.bottom
                }
                onTextChanged: {
                    /* Invoke load DB */
                    targetPage.loadDB()
                }
            }

            }

            Item {
                width: parent.width
                height: accountSymbol.height

            Rectangle {
                id: accountSymbol
                color: "silver" // "Unknown" color code
                width: units.gu(6)
                height: units.gu(6)
                border.width: 0
                radius: units.gu(0.9)
                anchors {
                   left: parent.left; top: parent.top
                }
            }

            Text {
                id: accountSymbolText
                text: "U"  /* Modified by accountName change */
                color: "white"
                font.pixelSize: units.gu(4)
                anchors {
                   horizontalCenter: accountSymbol.horizontalCenter; verticalCenter: accountSymbol.verticalCenter
                }
            }


            TextEdit {
                id: accountName
                text: "Unknown Account"
                anchors.leftMargin: units.gu(2)
                font.pixelSize: units.gu(2)
                readOnly: true
                anchors {
                   left: accountSymbol.right; verticalCenter: accountSymbol.verticalCenter
                }
            }

            }

            Item {
                anchors.topMargin: units.gu(10)
                width: parent.width
                height: localIcon.height


                MouseArea {
                    width: localIcon.width
                    height: localIcon.height

                    onClicked: {
                        console.log("EditTarget :: Change Local Folder")
                        apl.addPageToNextColumn(targetPage, Qt.resolvedUrl("LocalFileBrowser.qml"), {caller:localPath})
                    }
            Icon {
                id: localIcon
                name: "folder-symbolic"
                width: units.gu(6)
                height: width
                anchors {
                   left: parent.left; top: parent.top
                }
                }

            Text {
                id: localPath
                text: ""
                anchors.leftMargin: units.gu(3)
                anchors.verticalCenterOffset: 0
                font.pixelSize: units.gu(2)
                anchors {
                   left: localIcon.right; verticalCenter: localIcon.verticalCenter
                }
                onTextChanged: {
                    /* Invoke update DB */
                    targetPage.updateDB()
                    targetPage.loadDB()
                }
            }

            }

            }

            Item {
                anchors.topMargin: units.gu(10)
                width: parent.width
                height: remoteIcon.height


                MouseArea {
                    width: remoteIcon.width
                    height: remoteIcon.height

                    onClicked: {
                        console.log("EditTarget :: Change Remote Folder")
                         apl.addPageToNextColumn(targetPage, Qt.resolvedUrl("WebdavFileBrowser.qml"), {caller:remotePath, paramUsername: targetPage.accountUser, paramPassword: targetPage.accountPassword, paramServerUrl: targetPage.accountRemoteAddress})
                    }
            Icon {
                id: remoteIcon
                name: "network-server-symbolic"
                width: units.gu(6)
                height: width
                anchors {
                   left: parent.left; top: parent.top
                }
            }

            Text {
                id: remotePath
                text: ""
                anchors.leftMargin: units.gu(3)
                anchors.verticalCenterOffset: 0
                font.pixelSize: units.gu(2)
                anchors {
                   left: remoteIcon.right; verticalCenter: remoteIcon.verticalCenter
                }
                onTextChanged: {
                    /* Invoke update DB */
                    targetPage.updateDB()
                    targetPage.loadDB()
                }
            }

            }

            }

            Item {
                anchors.topMargin: units.gu(10)
                width: parent.width
                height: mobileDataLabel.height

            Label{
                id: mobileDataLabel
                font.pixelSize: units.gu(2)
                anchors.topMargin: units.gu(2)
                text: i18n.tr("Enable/Disable this Target")
                anchors {
                    left: parent.left; top: parent.top
                }
            }

            Switch{
                id: activeSwitch
                checked: null
                anchors {
                   right: parent.right; verticalCenter: mobileDataLabel.verticalCenter
                }
                onCheckedChanged: {
                    /* Invoke update DB */
                    targetPage.updateDB()
                    targetPage.loadDB()
                }
            }

            }

        }

    }


}


