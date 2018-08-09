import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import "../components"
import "webdav.js" as Webdav
import Ubuntu.OnlineAccounts 2.0
import Ubuntu.Components.ListItems 1.3 as ListItem



Page {
    id: accountSettingsPage

    property string accountName: accountConnection.target ? accountConnection.target.displayName : ""
    property bool authenticated: false
    property string host: ""
    property string username: ""
    property string password: ""

    header: PageHeader {
        id: header
        title: i18n.tr("General Settings")
        flickable: accountSettingsFlickable

        trailingActionBar{
            actions: [
                Action {
                    iconName: "contact"
                    onTriggered: PopupUtils.open(dialogComponent)
                }
            ]
        }
    }

    Component.onCompleted: {
        //connect to the signal emitted from webdav.js when credentials are validated
        Webdav.QmlObject.credentialsValid.connect(credentialsValid)
    }

    Timer {
        //timer starts when credentials are changed. once elapsed the credntials are tested.
        id: credentialsTimer
        interval: 1500;
        //running: true;
        repeat: false
        onTriggered: testConnection()
    }

    Flickable {
        id: accountSettingsFlickable
        
        anchors.fill: parent
        contentHeight: accountSettingsColumn.height
        
        Column {
            id: accountSettingsColumn
            
            spacing: units.gu(1.5)
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: units.gu(2) }
            
            Label {
                id: username
                //font.bold: true
                text: i18n.tr("User") + ": " + accountSettingsPage.username
            }

            Label {
                id: hostcloud
                //font.bold: true
                text: i18n.tr("Host") + ": " +  accountSettingsPage.host
            }
            
            
            Item {
                width: parent.width
                height: mobileDataLabel.implicitHeight + units.gu(1)
                
                Label{
                    id: mobileDataLabel
                    text: i18n.tr("Sync on Mobile Data")
                    anchors { left: parent.left; right: mobileData.left; verticalCenter: parent.verticalCenter }
                }
                
                Switch{
                    id: mobileData
                    checked: owncloud.settings.mobileData
                    anchors { right: parent.right; verticalCenter: parent.verticalCenter }                   
                    onCheckedChanged: {
                        owncloud.settings.mobileData = checked
                        inputChanged();
                    }
                }
            }

            Label {
                id: frequencyLabel
                text: i18n.tr("Sync Frequency")
            }

            OptionSelector {
                id: frequency
                width: parent.width

                    model: [0, 1, 2, 4, 6, 12, 24]

                delegate: OptionSelectorDelegate{text: frequency.model[index] === 0 ? i18n.tr("No Sync") : frequency.model[index] + " " + i18n.tr("hours")}

                onDelegateClicked: {
                    owncloud.settings.timer = model[index];
                    print("Index Changed: " + model[index]);
                    inputChanged();

                }

                onSelectedIndexChanged:{
                    console.log("SelectedIndexChanged: " + selectedIndex)
                }

                Component.onCompleted: {
                        frequencyTimer.start()
                }

                Timer{
                    id: frequencyTimer
                    interval: 200;
                    //running: true;
                    repeat: false
                    onTriggered: {
                        var index = frequency.model.indexOf(Number(owncloud.settings.timer));
                        console.log("[AccountsSettingsPage] - Set Frequency Index:" + index + " Value: " + frequency.model[index]);
                        frequency.selectedIndex = index;

                    }

                }
            }
        }
    }

/*
    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: i18n.tr("Delete Account ?")

            Button {
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(dialogue)
            }
            Button {
                id: okButton
                text: i18n.tr("Delete")
                color: UbuntuColors.red
                onClicked: {
                    owncloud.settings.clearSettings();
                    PopupUtils.close(dialogue)
                    owncloudsync.removeAllConfigs();
                    serviceController.removeServiceFile();

                }
            }
        }
    }*/

///////////////////////////////////////////////////
    //Add Online Account connection

    Timer {
        interval: 450
        running: true
        onTriggered: if (accounts.count === 0) {
            choose()
        } else {
            useAccount(accounts.get(0, "account"))
        }
    }


    function choose() {
            PopupUtils.open(dialogComponent)
        }

        function useAccount(account) {
            host = account.settings.host
            accountConnection.target = account
            account.authenticate({})
        }


        AccountModel {
            id: accounts
            applicationId: "ubsync_UBsync"
        }

        Connections {
            id: accountConnection
            target: null
            onAuthenticationReply: {
                var reply = authenticationData
                if ("errorCode" in reply) {
                    console.warn("Authentication error: " + reply.errorText + " (" + reply.errorCode + ")")
                    accountSettingsPage.authenticated = false
                } else {
                    accountSettingsPage.username = reply.Username
                    accountSettingsPage.password = reply.Password
                    accountSettingsPage.authenticated = true
                    testConnection()
                }
            }

        }

        Component {
            id: dialogComponent
            Dialog {
                id: dialog
                title: i18n.tr("Choose a Nextcloud Account")

                Repeater {
                    model: accounts
                    ListItem.Standard {
                        anchors { left: parent.left; right: parent.right }
                        height: units.gu(6)
                        text: model.displayName
                        onClicked: {
                            useAccount(model.account)
                            PopupUtils.close(dialog)
                        }
                    }
                }

                Label {
                    anchors {
                        left: parent.left; right: parent.right
                        margins: units.gu(1)
                    }
                    visible: accounts.count === 0
                    text: i18n.tr("No Nextcloud accounts available. Tap on the button below to add an account.")
                    wrapMode: Text.Wrap
                }

                Button {
                    text: i18n.tr("Add a new account")
                    onClicked: accounts.requestAccess(accounts.applicationId + "_nextcloud", {})
                }

                Button {
                    text: i18n.tr("Cancel")
                    onClicked: PopupUtils.close(dialog)
                }
            }
        }

/////////////////////////////////////////////////////////


    function inputChanged(){
        credentialsTimer.restart()
    }

    function testConnection(){

        if( accountSettingsPage.username && accountSettingsPage.password && accountSettingsPage.host){

            //save the credentials
            owncloud.settings.username = accountSettingsPage.username
            owncloud.settings.password = accountSettingsPage.password
            owncloud.settings.serverURL = accountSettingsPage.host

            Webdav.validateCredentials(accountSettingsPage.username,
                                       accountSettingsPage.password,
                                       accountSettingsPage.host);

        }
    }

    function credentialsValid(valid){
        console.log("Nextcloud Credentials Valid: " + valid);

        if(valid){
            owncloud.settings.credentialsVerfied = true
            if(serviceController.serviceRunning){
                serviceController.restartService()
            }else{
                serviceController.startService()
            }
        }else{
            console.log("failed to connect to: " + accountSettingsPages.host)
            //owncloud.settings.credentialsVerfied = false
        }
    }
}
