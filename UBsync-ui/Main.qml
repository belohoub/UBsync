/*
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/


import QtQuick 2.4
import Lomiri.Components 1.3
import Lomiri.Components.Popups 1.3
import QtQuick.LocalStorage 2.0

import "ui"
import "components"

// C++ Plugin
import OwncloudSync 1.0


import Qt.labs.settings 1.0
//import QtQuick.XmlListModel 2.0

MainView {
    id: owncloud
    property alias settings: ubsyncSettings
    property var applicationVersion
    property var applicationPatch
    property var returnPage

    // UBsync database
    property var db

    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "ubsync"
    applicationVersion: "0.7"
    applicationPatch: "5" // minor version

    anchorToKeyboard: true

    Settings {
        id: ubsyncSettings

        property int timer: 0
        property string owncloudcmdVersion
        property string owncloudSyncdVersion
        property string ubsyncVersion: "0.7"
        property string ubsyncVersionPatch: "0"

        property string color_targetActive: "forestgreen"
        property string color_targetInactive: "silver"
        property string color_targetAccountDisabled: "orange"

        property string color_accountEnabled: "steelblue"
        property string color_accountDisabled: "indianred"
        property string color_accountEnabledNotConfigured: "purple"

        /* deprecated options */
        property string password: ""
        property string serverURL: ""
        property string username: ""


        function clearSettings(){
            timer = 0
        }

    }

    /* Init database */
    function createDB() {

        owncloud.db = LocalStorage.openDatabaseSync("UBsync", "1.0", "UBsync", 1000000);

        owncloud.db.transaction(
                    function(tx) {
                        // Create tables if it doesn't already exist
                        tx.executeSql('CREATE TABLE IF NOT EXISTS SyncAccounts(accountID INTEGER PRIMARY KEY, accountName TEXT, remoteAddress TEXT, remoteUser TEXT, syncHidden BOOLEAN, useMobileData BOOLEAN, syncFreq INTEGER, serviceName TEXT)');
                        tx.executeSql('CREATE TABLE IF NOT EXISTS SyncTargets(targetID INTEGER PRIMARY KEY AUTOINCREMENT, accountID INTEGER, localPath TEXT, remotePath TEXT, targetName TEXT, active BOOLEAN, lastSync TEXT)');

                        // to correct strcuture for testers
                        // TODO remove in future releases
                        try {
                            tx.executeSql('ALTER TABLE SyncAccounts ADD COLUMN serviceName TEXT' );
                            tx.executeSql('ALTER TABLE SyncTargets ADD COLUMN lastSync TEXT');
                        } catch (error) {
                            // Nothink to do
                            print("Database structure update NOT needed.")
                        }
                    }
                )
    }

    OwncloudSync{
        id: owncloudsync
        Component.onCompleted: console.log(owncloudsync.logPath())
    }

    DaemonController{
        //dbus interface to the running daemon
        id: daemonController
    }

    ServiceController {
        id: serviceController
        serviceName: "OwncloudSyncd"
        Component.onCompleted: {

            //Create the upstart files
            if (!serviceController.serviceFileInstalled) {
                print("Service file not installed. Installing now.")
                serviceController.installServiceFile();
            }

            /* config file version - related update actions */
            if ((parseFloat(owncloud.settings.ubsyncVersion) < 0.7) || (owncloud.settings.username != "")) {
                // remove deprecated options
                owncloud.settings.password = ""
                owncloud.settings.serverURL = ""
                owncloud.settings.username = ""
                // update database structure and database ...
                createDB()
                // TODO no migration here ... ???
            } if ((parseFloat(owncloud.settings.ubsyncVersion) === parseFloat(owncloud.applicationVersion)) && (parseInt(owncloud.settings.ubsyncVersionPatch) === parseInt(owncloud.applicationPatch))) {
                // do nothing
            }  if (parseFloat(owncloud.settings.ubsyncVersion) > parseFloat(owncloud.applicationVersion)) {
                // Newer configuration file!
                // do nothing
                // TODO?
            } else {
                // probably a new installation, patch upgrade
                createDB()
            }

            // strore current app version
            owncloud.settings.ubsyncVersion = owncloud.applicationVersion
            owncloud.settings.ubsyncVersionPatch = owncloud.applicationPatch

          //  if (!serviceController.serviceRunning) {
          //      print("Service not running. Starting now.")
          //      serviceController.startService();
          //  }
        }
    }

    width: units.gu(60)
    height: units.gu(75)

    AdaptivePageLayout {
        id: apl
        //property int windowWidth: width/units.gu(1)
        property int maxWidth: 91 //width in grid units
        property bool connected: false
        property bool testingConnection: true
        property var  accountSettings // TODO remove?
        anchors.fill: parent
        //primaryPageSource: Qt.resolvedUrl("ui/TargetsPage.qml")
        primaryPageSource: Qt.resolvedUrl("ui/MenuPage.qml")
        //primaryPageSource: (width > units.gu(apl.maxWidth)) ? Qt.resolvedUrl("ui/MenuPage.qml") : Qt.resolvedUrl("ui/TargetsPage.qml")


        layouts: PageColumnsLayout {
            when: width > units.gu(apl.maxWidth)

            // column #0
            PageColumn {
                minimumWidth: units.gu(10)
                maximumWidth: units.gu(apl.maxWidth)
                preferredWidth: units.gu(40)

            }
            // column #1
            PageColumn {
                fillWidth: true

            }
        }
    }
}
