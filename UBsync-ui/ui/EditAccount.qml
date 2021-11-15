import QtQuick 2.4
import Ubuntu.Components 1.3

import QtQuick.LocalStorage 2.0


Page {
    id: accountPage

    property var db

    /* Accepted paramters */
    property string defaultAccountName: "Unknown Name"   /* Used only when DB entry is empty */
    property string remoteAddress: "https://owncloud.tld/"
    property string remoteUser: "Unknown User"
    property int accountID: 0

    /* Settings */
    property bool syncHidden: false
    property bool useMobileData: false
    property int syncFreq: 1



    function loadDB(index) {

        accountPage.db = LocalStorage.openDatabaseSync("UBsync", "1.0", "UBsync", 1000000);

        console.log("Loading SyncAccounts index " + index)

        accountPage.db.transaction(
                    function(tx) {
                        // Create table if it doesn't already exist
                        tx.executeSql('CREATE TABLE IF NOT EXISTS SyncAccounts(accountID INTEGER PRIMARY KEY, accountName TEXT, remoteAddress TEXT, remoteUser TEXT, syncHidden BOOLEAN, useMobileData BOOLEAN, syncFreq INTEGER)');

                        // load selected account
                        var rs = tx.executeSql('SELECT * FROM SyncAccounts WHERE accountID = (?)', [index]);

                        for(var i = 0; i < rs.rows.length; i++) {
                            //accountID.text = "ID: " + rs.rows.item(i).accountID
                            accountName.text = rs.rows.item(i).accountName

                            accountPage.remoteAddress = rs.rows.item(i).remoteAddress
                            remoteText.text = accountPage.remoteAddress

                            accountPage.remoteUser = rs.rows.item(i).remoteUser
                            usernameText.text = accountPage.remoteUser

                            accountPage.syncHidden = rs.rows.item(i).syncHidden
                            hiddenFilesSwitch.checked = accountPage.syncHidden

                            accountPage.useMobileData = rs.rows.item(i).useMobileData
                            mobileDataSwitch.checked = accountPage.useMobileData

                            accountPage.syncFreq = rs.rows.item(i).syncFreq
                            var freqIndex = syncFrequency.model.indexOf(rs.rows.item(i).syncFreq)
                            syncFrequency.selectedIndex = freqIndex
                        }
                    }
                    )
    }

    function updateDB(index) {
        accountPage.db.transaction(
                    function(tx) {

                        var rs = tx.executeSql('SELECT * FROM SyncAccounts WHERE accountID = (?)', [index]);

                        if (rs.rows.length === 0) {
                            console.log("Inserting SyncAccounts index " + index)
                            tx.executeSql('INSERT INTO SyncAccounts VALUES((?), (?), (?), (?), 0, 0, 1)', [
                                              index,
                                              accountName.text,
                                              remoteText.text,
                                              usernameText.text]);
                        } else {
                            console.log("Updating SyncAccounts index " + index + ": ")
                            console.log("  " + accountName.text)
                            console.log("  " + remoteText.text)
                            console.log("  " + usernameText.text)
                            tx.executeSql('UPDATE SyncAccounts SET accountName=(?), remoteAddress=(?), remoteUser=(?), syncHidden=(?), useMobileData=(?), syncFreq=(?) WHERE accountID = (?)', [
                                              accountName.text,
                                              remoteText.text,
                                              usernameText.text,
                                              hiddenFilesSwitch.checked,
                                              mobileDataSwitch.checked,
                                              accountPage.syncFreq,
                                              index]);
                        }
                    }
                    )
    }

    Connections {
            target: accountPage

            onActiveChanged: {
                /* re-render anytime page is shown */
                console.log("editAccountPage activated")
                accountPage.loadDB(accountPage.accountID)
                accountPage.updateDB(accountPage.accountID)
            }

            /*onCompleted: {
                console.log("editAccountPage created")
                accountPage.loadDB(accountPage.accountID)
                accountPage.updateDB(accountPage.accountID)
            }*/
        }


    header: PageHeader {
        id: header
        title: i18n.tr("Account Settings")
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
                height: accountSymbol.height
                anchors.topMargin: units.gu(10)

            Rectangle {
                id: accountSymbol
                color: "steelblue" /*"#0000B5"*/
                width: units.gu(15)
                height: units.gu(15)
                border.width: 0
                radius: units.gu(2)
                anchors {
                   left: parent.left; top: parent.top
                }
            }

            Text {
                id: accountSymbolText
                text: "U"  /* Modified by accountName change */
                color: "white"
                font.pixelSize: units.gu(10)
                anchors {
                   horizontalCenter: accountSymbol.horizontalCenter; verticalCenter: accountSymbol.verticalCenter
                }
            }


            TextEdit {
                id: accountName
                text: accountPage.defaultAccountName
                anchors.leftMargin: units.gu(2)
                font.pixelSize: units.gu(3)
                readOnly: true
                anchors {
                   left: accountSymbol.right; top: accountSymbol.top
                }
                /*onTextChanged: {
                    accountSymbolText.text = "" + text.charAt(0).toUpperCase()
                    // Invoke update DB
                    accountPage.updateDB(accountPage.accountID)
                }*/
            }


            Item {
                width: accountNameEditIcon.width
                height: accountNameEditIcon.height
                anchors {
                   right: parent.right; top: targetSymbol.top
                }

                MouseArea {
                    width: accountNameEditIcon.width
                    height: accountNameEditIcon.height

                    onClicked: {
                        /* Init name editing */
                        if (accountName.readOnly === true) {
                            accountName.readOnly = false;
                            accountName.forceActiveFocus()
                            accountName.cursorVisible = true
                            accountNameEditIcon.name = "ok"
                            //targetName.cursorPosition = 0
                            console.log("Change Name Start")
                        } else {
                            accountName.readOnly = true;
                            accountNameEditIcon.name = "edit"
                            console.log("Change Name Finished");
                            accountPage.updateDB(accountPage.accountID);
                            accountSymbolText.text = "" + accountName.text.charAt(0).toUpperCase();
                        }
                    }
                }
                Icon {
                    id: accountNameEditIcon
                    name: "edit"
                    width: units.gu(4)
                    height: width
                }
            }


            Text {
                id: accountID
                text: "ID: " + accountPage.accountID
                anchors.leftMargin: units.gu(2)
                anchors.topMargin: units.gu(1)
                font.pixelSize: units.gu(3)
                anchors {
                   left: accountSymbol.right; top: accountName.bottom
                }
                onTextChanged: {
                    /* Invoke load DB */
                    accountPage.loadDB(accountPage.accountID)
                }
            }

            }

            Item {
                anchors.topMargin: units.gu(10)
                width: parent.width
                height: remoteIcon.height

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
                id: remoteText
                text: "" + accountPage.remoteAddress
                anchors.leftMargin: units.gu(3)
                anchors.verticalCenterOffset: 0
                font.pixelSize: units.gu(2)
                anchors {
                   left: remoteIcon.right; verticalCenter: remoteIcon.verticalCenter
                }
            }

            }

            Item {
                anchors.topMargin: units.gu(10)
                width: parent.width
                height: remoteIcon.height

            Icon {
                id: usernameIcon
                name: "account"
                width: units.gu(6)
                height: width
                anchors {
                    left: parent.left; top: parent.top
                }
            }

            Text {
                id: usernameText
                text: "" + accountPage.remoteUser
                anchors.leftMargin: units.gu(3)
                anchors.verticalCenterOffset: 0
                font.pixelSize: units.gu(2)
                anchors {
                   left: usernameIcon.right; verticalCenter: usernameIcon.verticalCenter
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
                text: i18n.tr("Sync on Mobile Data")
                anchors {
                    left: parent.left; top: parent.top
                }
            }

            Switch{
                id: mobileDataSwitch
                checked: false
                anchors {
                   right: parent.right; verticalCenter: mobileDataLabel.verticalCenter
                }
                onCheckedChanged: {
                    accountPage.useMobileData = mobileDataSwitch.checked
                    /* Invoke update DB */
                    accountPage.updateDB(accountPage.accountID)
                }
            }

            }

            Item {
                anchors.topMargin: units.gu(10)
                width: parent.width
                height: hiddenFilesLabel.height

            Label{
                id: hiddenFilesLabel
                font.pixelSize: units.gu(2)
                anchors.topMargin: units.gu(2)
                text: i18n.tr("Sync hidden files")
                anchors {
                    left: parent.left; top: parent.top
                }
            }

            Switch{
                id: hiddenFilesSwitch
                checked: false
                anchors {
                   right: parent.right; verticalCenter: hiddenFilesLabel.verticalCenter
                }
                onCheckedChanged: {
                    accountPage.syncHidden = hiddenFilesSwitch.checked
                    /* Invoke update DB */
                    accountPage.updateDB(accountPage.accountID)
                }
            }

            }

            Item {
                anchors.topMargin: units.gu(10)
                width: parent.width
                height: frequencyLabel.height + syncFrequency.height

            Label {
                id: frequencyLabel
                font.pixelSize: units.gu(2)
                anchors.topMargin: units.gu(2)
                text: i18n.tr("Sync Frequency")
                anchors {
                    left: parent.left; top: parent.top
                }
            }

            OptionSelector {
                id: syncFrequency
                selectedIndex: 0
                width: units.gu(20)

                anchors {
                   right: parent.right; verticalCenter: frequencyLabel.verticalCenter
                }

                model: [0, 1, 2, 4, 6, 12, 24, 48, 168]

                delegate: OptionSelectorDelegate {
                    text: syncFrequency.model[index] === 0 ? i18n.tr("No Sync") : syncFrequency.model[index] + " " + i18n.tr("hours")
                }

                onSelectedIndexChanged:{
                    console.log("SelectedIndexChanged: " + selectedIndex)
                }

                onDelegateClicked: {
                    accountPage.syncFreq = Number(model[index])
                    syncFrequency.selectedIndex = index;
                    /* Invoke update DB */
                    accountPage.updateDB(accountPage.accountID)
                }

            }
            }

        }

    }


}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
