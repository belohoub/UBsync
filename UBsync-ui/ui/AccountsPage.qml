import QtQuick 2.4
import Ubuntu.Components 1.3
import "../components"
import Ubuntu.OnlineAccounts 2.0

import QtQuick.LocalStorage 2.0


Page {
    id: accountsPage

    property var db

    property string requestAccount: ""
    property bool accountsLoaded: false // accounts may be not ready ...

    /* load current data from DB */
    function loadDB() {

        if (accounts.ready === false) {
            return
        } else {
            accountsLoaded = true
        }

        accountListModel.clear();

        accountsPage.db = LocalStorage.openDatabaseSync("UBsync", "1.0", "UBsync", 1000000);

        console.log("AccountsPage :: Loading accountsPage data");

        accountsPage.db.transaction(
                    function(tx) {
                        // load selected account
                        var rs = tx.executeSql('SELECT * FROM SyncAccounts');

                        for(var i = 0; i < rs.rows.length; i++) {
                            console.log("AccountsPage :: Loading accountsPage: " + rs.rows.item(i).accountName + "; CNT: " + accounts.count + "; ID: " + rs.rows.item(i).accountID)
                            var j = 0
                            for (j = 0; j < accounts.count; j++) {
                                if (accounts.get(j, "account").accountId === rs.rows.item(i).accountID) {
                                    console.log("AccountsPage :: Loading accountsPage: " + rs.rows.item(i).accountName + "; " + accounts.count + "; " + accounts.get(j, "account").accountId)
                                    // Add enabled accounts to the list
                                    accountListModel.append({"accountID": rs.rows.item(i).accountID, "accountName": rs.rows.item(i).accountName, "color": owncloud.settings.color_accountEnabled, "isEditable": true})
                                    break
                                }
                            }

                            if (j === accounts.count) {
                                // account is NOT enabled!
                                accountListModel.append({"accountID": rs.rows.item(i).accountID, "accountName": rs.rows.item(i).accountName, "color" : owncloud.settings.color_accountDisabled, "isEditable": true})
                                console.log("AccountsPage :: Color is " + owncloud.settings.color_accountDisabled + " - account NOT enabled")
                            }
                        }

                        // Add enabled but unconfigured accounts to the end of the list
                        for (j = 0; j < accounts.count; j++) {
                            for(i = 0; i < rs.rows.length; i++) {
                                if (accounts.get(j, "account").accountId === rs.rows.item(i).accountID) {
                                    break
                                }
                            }
                            if (i === rs.rows.length) {
                                // Account was not found in database
                                accountListModel.append({"accountID": accounts.get(j, "account").accountId, "accountName": accounts.get(j, "account").displayName, "color" : owncloud.settings.color_accountEnabledNotConfigured, "isEditable": false})
                                console.log("AccountsPage :: Color is " + owncloud.settings.color_accountEnabledNotConfigured + " - account NOT configured")
                            }
                        }
                    }
                )

        accountList.forceLayout();
    }

    /* remove account */
    function removeAccount(accountID) {

        accountListModel.clear();

        accountsPage.db = LocalStorage.openDatabaseSync("UBsync", "1.0", "UBsync", 1000000);

        console.log("AccountsPage :: Removing account " + accountID)

        accountsPage.db.transaction(
                    function(tx) {
                        // remove selected account from DB
                        var rs = tx.executeSql('DELETE FROM SyncAccounts WHERE accountID = (?)', [accountID]);
                    }
                )

        // TODO - disable account in online accounts ?

        accountsPage.loadDB();
        accountList.forceLayout();
    }

    Connections {
            target: accountsPage

            onActiveChanged: {
                /* re-render anytime page is shown */
                console.log("AccountsPage :: accountsPage activated")
                accountsPage.loadDB()
            }
        }

    ListModel {
        id: accountListModel

        ListElement {
            accountID: 0
            accountName: "Unknown"
            color: "silver"
            isEditable: false  // account has a database entry
        }

        Component.onCompleted: {
            console.log("AccountsPage :: accountsPage created")

            accountsPage.loadDB()
        }
    }


    header: PageHeader {
        id: header
        title: i18n.tr("Online Accounts")

        trailingActionBar{
            actions: [
                Action {
                    iconName: "add"
                    onTriggered: {
                        console.log("AccountsPage :: Add New Online account.")
                        apl.addPageToNextColumn(accountsPage, Qt.resolvedUrl("RequestAccountPage.qml"))
                    }
                }
            ]
        }
    }

    Timer {
        id: newAccountTimer
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            // if accounts were not ready update again as soon as possible ...
            if (accountsLoaded === false) {
                accountsPage.loadDB()
                if (accountsLoaded === false) {
                    // if still not ready, wait ...
                    return
                }
            }

            if (accounts.count > accountListModel.count) {
                accountsPage.loadDB()
            }

            /* handle account requests */
            if (requestAccount.localeCompare("nextcloud") === 0) {
                console.log("AccountsPage :: NextCloud activation request!")
                accounts.requestAccess(accounts.applicationId + "_nextcloud", {})
            } else if (requestAccount.localeCompare("owncloud") === 0) {
                console.log("AccountsPage :: OwnCloud activation request!")
                accounts.requestAccess(accounts.applicationId + "_owncloud", {})
            }
            requestAccount = ""
        }
    }

    Connections {
          id: accountConnection
          target: accounts

          onAccessReply: {
              console.log("AccountsPage :: onAccessReply()")

              //console.log(JSON.stringify(reply.account))
              //console.log(JSON.stringify(authenticationData))

              if ("errorCode" in reply) {
                  console.warn("Authentication error: " + reply.errorText + " (" + reply.errorCode + ")")
                  // TODO: report an error to user ?

              } else {
                  var account = reply.account;

                  /* TODO: activate in debug mode? */
                  //console.log("AccountsPage :: Account details are: " + " (" + account.accountId + ")" + " " + account.settings.host + "; " + authenticationData.Username + ":" + authenticationData.Password )
                  apl.addPageToNextColumn(accountsPage, Qt.resolvedUrl("EditAccount.qml"), {accountID: account.accountId, defaultAccountName: account.displayName, remoteAddress: account.settings.host, remoteUser: authenticationData.Username, isEditable: true })

                  // update
                  accountsPage.loadDB()
              }

          }
    }

    Connections {
          id: accountConnectionAccount
          target: null

          onAuthenticationReply: {
              console.log("AccountsPage :: onAuthenticationReply()")
              var reply = authenticationData

              if ("errorCode" in reply) {
                  console.warn("Authentication error: " + reply.errorText + " (" + reply.errorCode + ")")
                  // TODO: report an error to user ?
              } else {
                  /* TODO: activate in debug mode? */
                  //console.log("AccountsPage :: Account details are: " + " (" + account.accountId + ")" + " " + account.settings.host + "; " + authenticationData.Username + ":" + authenticationData.Password )
                  apl.addPageToNextColumn(accountsPage, Qt.resolvedUrl("EditAccount.qml"), {accountID: target.accountId, defaultAccountName: target.displayName, remoteAddress: target.settings.host, remoteUser: reply.Username, isEditable: true })

                  // update
                  accountsPage.loadDB()
              }
          }
    }

    AccountModel {
        id: accounts
        applicationId: "ubsync_UBsync"
    }

    Item {
        //Shown only if there are no items in accounts
        anchors{centerIn: parent}
        visible: !accountListModel.count
        width: parent.width - units.gu(4)

        Label{
            wrapMode: Text.Wrap
            text: i18n.tr("No accounts, press")
            anchors{left: parent.left; right: parent.right; bottom: addIcon.top; bottomMargin: units.gu(2)}
            horizontalAlignment: Text.AlignHCenter
        }

        Icon {
            id: addIcon
            name: "add"
            width: units.gu(4)
            height: width
            anchors{centerIn: parent}
        }

        Label{
            wrapMode: Text.Wrap
            text: i18n.tr("on the panel to add a new account")
            anchors{left: parent.left; right: parent.right; top: addIcon.bottom; topMargin: units.gu(2)}
            horizontalAlignment: Text.AlignHCenter
        }
    }

    ListView {
        id: accountList
        model: accountListModel
        anchors{left:parent.left; right:parent.right; top:header.bottom; bottom:parent.bottom; bottomMargin:units.gu(2)}
        clip: true
        visible: accountListModel.count

        onMovementEnded: {
            /* update page when moving ...*/
            accountsPage.loadDB()
        }

        delegate: ListItem {
            height: accountColumn.height
            anchors{left:parent.left; right:parent.right}

            onClicked: {
                if (model.isEditable === true) {
                    apl.addPageToNextColumn(accountsPage, Qt.resolvedUrl("EditAccount.qml"), {accountID: model.accountID, isEditable: model.isEditable})
                } else {
                    for (var j = 0; j < accounts.count; j++) {
                        if (accounts.get(j, "account").accountId === model.accountID) {
                            accountConnectionAccount.target = accounts.get(j, "account")
                            accounts.get(j, "account").authenticate({})
                        }
                    }
                }
            }

            Item {
                id: accountColumn
                height: units.gu(12)

                anchors.leftMargin: units.gu(2)

                //spacing: units.gu(1)
                anchors {
                    top: parent.top; left: parent.left; right: parent.right; margins:units.gu(2)
                }

                Rectangle {
                    id: accountIcon
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
                    id: accountIconText
                    text: model.accountName.charAt(0).toUpperCase()
                    color: "white"
                    font.pixelSize: units.gu(6)
                    anchors {
                       horizontalCenter: accountIcon.horizontalCenter; verticalCenter: accountIcon.verticalCenter
                    }
                }

                Label {
                    id: accountName
                    wrapMode: Text.Wrap
                    width: parent.width - accountIcon.width - units.gu(4)
                    text: model.accountName
                    height: units.gu(6)
                    font.pixelSize: units.gu(3)
                    anchors.leftMargin: units.gu(2)
                    anchors {
                       left: accountIcon.right; top: parent.top
                    }
                }

                /*Label {
                    id: accountID
                    text: model.accountID
                    font.pixelSize: units.gu(2)
                    anchors.leftMargin: units.gu(2)
                    anchors {
                       left: accountIcon.right; top: accountName.bottom
                    }
                }*/

                /* TODO display number of sync targets ? */

            }


            leadingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"
                        enabled: model.isEditable
                        text: ""
                        onTriggered: {
                            accountsPage.removeAccount(model.accountID)
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
                            if (model.isEditable === true) {
                                apl.addPageToNextColumn(accountsPage, Qt.resolvedUrl("EditAccount.qml"), {accountID: model.accountID, isEditable: model.isEditable})
                            } else {
                                for (var j = 0; j < accounts.count; j++) {
                                    if (accounts.get(j, "account").accountId === model.accountID) {
                                        accountConnectionAccount.target = accounts.get(j, "account")
                                        accounts.get(j, "account").authenticate({})
                                    }
                                }
                            }
                        }
                    },

                    Action {
                        iconName: "note-new"
                        text: ""
                        enabled: model.isEditable
                        onTriggered: {
                            apl.addPageToNextColumn(accountsPage, Qt.resolvedUrl("EditTarget.qml"), {targetID: 0, accountID: model.accountID})
                        }
                    }
                ]
            }
        }
    }



}
