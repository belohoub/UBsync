import QtQuick 2.4
import Lomiri.Components 1.3

import Lomiri.OnlineAccounts 2.0

import QtQuick.LocalStorage 2.0


Page {
    id: accountPage

    property var db

    /* Accepted paramters */
    property string defaultAccountName: "Unknown Name"   /* Used only when DB entry is empty */
    property string remoteAddress: "https://owncloud.tld/"
    property string remoteUser: "Unknown User"
    property int accountID: 0
    property bool isEditable: false // Account can be updated

    /* Settings */
    property bool syncHidden: false
    property bool useMobileData: false
    property int syncFreq: 1

    // accounts may be not ready ...
    property bool accountsLoaded: false

    function loadDB(index) {

        if (accounts.ready === false) {
            return
        } else {
            accountsLoaded = true
        }

        accountPage.db = LocalStorage.openDatabaseSync("UBsync", "1.0", "UBsync", 1000000);

        console.log("EditAccount :: Loading SyncAccounts index " + index)

        var hasDatabaseEntry = false

        accountPage.db.transaction(
                    function(tx) {
                        // Create table if it doesn't already exist
                        //tx.executeSql('CREATE TABLE IF NOT EXISTS SyncAccounts(accountID INTEGER PRIMARY KEY, accountName TEXT, remoteAddress TEXT, remoteUser TEXT, syncHidden BOOLEAN, useMobileData BOOLEAN, syncFreq INTEGER)');

                        // load selected account
                        var rs = tx.executeSql('SELECT * FROM SyncAccounts WHERE accountID = (?)', [index]);

                        for(var i = 0; i < rs.rows.length; i++) {
                            hasDatabaseEntry = true

                            //accountID.text = "ID: " + rs.rows.item(i).accountID
                            accountName.text = rs.rows.item(i).accountName
                            accountSymbolText.text = "" + accountName.text.charAt(0).toUpperCase();

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

        if (hasDatabaseEntry === false) {
            accountSymbol.color = owncloud.settings.color_accountEnabledNotConfigured // account NOT Configured!
            accountStateDescription.text = i18n.tr("Not Configured Account") + "<br>(" + i18n.tr("related targets will NOT sync") + ")"
            accountStateIcon.name = "dialog-warning-symbolic"
        } else {
            // test if account is enabled in online accounts
            accountSymbol.color = owncloud.settings.color_accountDisabled // color for disabled accounts
            accountStateDescription.text = i18n.tr("Disabled Account")  + "<br>(" + i18n.tr("related targets will NOT sync") + ")"
            accountStateIcon.name = "dialog-warning-symbolic"
            for (var j = 0; j < accounts.count; j++) {
                if (accounts.get(j, "account").accountId === index) {
                    // account is enabled!
                    accountSymbol.color = owncloud.settings.color_accountEnabled
                    accountStateDescription.text = i18n.tr("Enabled Account") + "<br>(" + i18n.tr("related targets will sync") + ")"
                    accountStateIcon.name = "info"
                    break
                }
            }
        }
    }

    function updateDB(index) {
        if (isEditable === false) {
            return
        }

        accountPage.db.transaction(
                    function(tx) {

                        var rs = tx.executeSql('SELECT * FROM SyncAccounts WHERE accountID = (?)', [index]);

                        if (rs.rows.length === 0) {
                            console.log("EditAccount :: Inserting SyncAccounts index " + index)
                            tx.executeSql('INSERT INTO SyncAccounts VALUES((?), (?), (?), (?), 0, 0, 1, "")', [
                                              index,
                                              accountName.text,
                                              remoteText.text,
                                              usernameText.text]);
                        } else {
                            console.log("EditAccount :: Updating SyncAccounts index " + index + ": ")
                            console.log("EditAccount ::   " + accountName.text)
                            console.log("EditAccount ::   " + remoteText.text)
                            console.log("EditAccount ::   " + usernameText.text)
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
                accountPage.loadDB(accountPage.accountID)
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
            target: accountPage

            onActiveChanged: {
                /* re-render anytime page is shown */
                console.log("EditAccount :: editAccountPage activated")
                // load from DB if already exist
                accountPage.loadDB(accountPage.accountID)
                // Implicit save of the new account happens here
                // Expicit DB ebntry creation was confusing for users, thus DB entry is created implicitly
                // Any conflict should not happen, as accounts are unique in the system
                accountPage.updateDB(accountPage.accountID)
                // load to update view ...
                accountPage.loadDB(accountPage.accountID)
            }
        }


    header: PageHeader {
        id: header
        title: i18n.tr("Account Settings")
        flickable: flickable

        trailingActionBar{
            actions: [
                Action {
                    iconName: "note-new"
                    text: i18n.tr("New Target")
                    onTriggered: {
                        apl.addPageToNextColumn(accountPage, Qt.resolvedUrl("EditTarget.qml"), {targetID: 0, accountID: accountPage.accountID})
                    }
                }
            ]
        }
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentHeight: accountEditColumn.height
        flickableDirection: Flickable.AutoFlickIfNeeded

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
                color: "silver" //default "unknown" color
                width: units.gu(15)
                height: units.gu(15)
                border.width: 0
                radius: units.gu(2)
                anchors {
                   left: parent.left; top: parent.top
                }
            }

            Label {
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
                height: accountSymbol.height/3
                color: accountID.color // inherit text color from the element following the system color theme
                anchors.leftMargin: units.gu(2)
                font.pixelSize: units.gu(3)
                readOnly: true
                wrapMode: TextEdit.WrapAnywhere
                inputMethodHints: Qt.ImhNoPredictiveText
                width: parent.width - accountSymbol.width - accountNameEditIcon.width - units.gu(4)
                anchors {
                   left: accountSymbol.right; top: accountSymbol.top
                }
            }


            Item {
                width: accountNameEditIcon.width
                height: accountNameEditIcon.height
                visible: isEditable
                anchors {
                   right: parent.right; top: accountSymbol.top
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
                            console.log("EditAccount :: Change Name Start")
                        } else {
                            accountName.readOnly = true;
                            accountNameEditIcon.name = "edit"
                            console.log("EditAccount :: Change Name Finished");
                            accountPage.updateDB(accountPage.accountID)
                            accountPage.loadDB(accountPage.accountID)
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


            Label {
                id: accountID
                text: "ID: " + accountPage.accountID
                anchors.leftMargin: units.gu(2)
                anchors.topMargin: units.gu(1)
                anchors.bottomMargin: units.gu(1)
                font.pixelSize: units.gu(3)
                anchors {
                   left: accountSymbol.right; bottom: accountSymbol.bottom
                }
                onTextChanged: {
                    /* Invoke load DB */
                    accountPage.loadDB(accountPage.accountID)
                    // Explicit save was confusing for users, thus DB entry is created implicitly
                    // Any conflict should not happen, as accounts are unique in the system
                    accountPage.updateDB(accountPage.accountID)
                    // load to update view ...
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

            Label {
                id: remoteText
                text: "" + accountPage.remoteAddress
                wrapMode: Text.WrapAnywhere
                maximumLineCount: 2
                //width: parent.width - remoteIcon.width - units.gu(10)
                width: accountName.width + units.gu(12) /* TODO remove this hack - computing width from parent fails here ... why? */
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

            Label {
                id: usernameText
                text: "" + accountPage.remoteUser
                wrapMode: Text.WrapAnywhere
                maximumLineCount: 2
                //width: parent.width - usernameIcon.width - units.gu(10)
                width: accountName.width + units.gu(12) /* TODO remove this hack - computing width from parent fails here ... why? */
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
                enabled: isEditable
                anchors {
                   right: parent.right; verticalCenter: mobileDataLabel.verticalCenter
                }
                onCheckedChanged: {
                    accountPage.useMobileData = mobileDataSwitch.checked
                    /* Invoke update DB */
                    accountPage.updateDB(accountPage.accountID)
                    accountPage.loadDB(accountPage.accountID)
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
                enabled: isEditable
                anchors {
                   right: parent.right; verticalCenter: hiddenFilesLabel.verticalCenter
                }
                onCheckedChanged: {
                    accountPage.syncHidden = hiddenFilesSwitch.checked
                    /* Invoke update DB */
                    accountPage.updateDB(accountPage.accountID)
                    accountPage.loadDB(accountPage.accountID)
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
                enabled: isEditable
                width: units.gu(20)

                anchors {
                   right: parent.right
                   //verticalCenter: frequencyLabel.verticalCenter
                   top: frequencyLabel.bottom
                }

                model: [0, 1, 2, 4, 6, 12, 24, 48, 168]

                delegate: OptionSelectorDelegate {
                    text: syncFrequency.model[index] === 0 ? i18n.tr("No Sync") : syncFrequency.model[index] + " " + i18n.tr("hour", "hours", syncFrequency.model[index])
                }

                onSelectedIndexChanged:{
                    console.log("EditAccount :: SelectedIndexChanged: " + selectedIndex)
                }

                onDelegateClicked: {
                    accountPage.syncFreq = Number(model[index])
                    syncFrequency.selectedIndex = index;
                    /* Invoke update DB */
                    accountPage.updateDB(accountPage.accountID)
                    accountPage.loadDB(accountPage.accountID)
                }

            }
            }


            /* State information */
            Item {
                width: parent.width
                height: 2 * accountStateIcon.height + units.gu(10)

                Icon {
                    id: accountStateIcon
                    visible: (serviceController.serviceRunning)
                    name: "info"
                    width: units.gu(6)
                    height: width
                    anchors {
                       left: parent.left
                       bottom: parent.bottom
                    }
                }

                Icon {
                    id: syncServiceIcon
                    visible: !(serviceController.serviceRunning)
                    name: "dialog-warning-symbolic"
                    width: units.gu(6)
                    height: width
                    anchors {
                       left: parent.left
                       bottom: parent.bottom
                    }
                }

                Label {
                    id: accountStateDescription
                    visible: (serviceController.serviceRunning)
                    text: ""
                    anchors.leftMargin: units.gu(2)
                    anchors.topMargin: units.gu(1)
                    font.pixelSize: units.gu(2)
                    anchors {
                        left: accountStateIcon.right; verticalCenter: accountStateIcon.verticalCenter
                        leftMargin: units.gu(2)
                    }
                }

                Label{
                        id: syncServiceStatus
                        visible: !(serviceController.serviceRunning)
                        font.pixelSize: units.gu(2)
                        width: parent.width - accountStateIcon.width - units.gu(4)
                        wrapMode: Text.WordWrap
                        text: serviceController.serviceRunning ? "" : i18n.tr("Synchronization service not running! Please, go to UBsync Settings and start the sync service, otherwise the target synchronization will not begin.")
                        anchors {
                            left: accountStateIcon.right; verticalCenter: accountStateIcon.verticalCenter
                            leftMargin: units.gu(2)
                            right: parent.right
                            rightMargin: units.gu(2)
                        }
                    }
            }

        }

    }


}
