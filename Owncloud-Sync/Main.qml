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
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
//import Ubuntu.Components.Pickers 1.0
import "ui"
import "components"

// C++ Plugin
import OwncloudSync 1.0


import Qt.labs.settings 1.0
//import QtQuick.XmlListModel 2.0

MainView {
    id: owncloud
    property alias settings: accountSettings
    // objectName for functional testing purposes (autopilot-qt5)
    objectName: "mainView"

    // Note! applicationName needs to match the "name" field of the click manifest
    applicationName: "ubsync"

    anchorToKeyboard: true

    Settings {
        id: accountSettings

        property string password
        property string username
        property string serverURL
        property bool credentialsVerfied: false
        property int timer: 0
        property bool mobileData: false
        property string lastSync
        property string owncloudcmdVersion

        function clearSettings(){
            password = ""
            username = ""
            serverURL = ""
            credentialsVerfied = false
            timer = 0
            mobileData = false
            lastSync = ""
        }

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
        property var  accountSettings
        anchors.fill: parent
        primaryPageSource: Qt.resolvedUrl("ui/Accounts.qml")
        //primaryPageSource: accountSettings.credentialsVerfied ? Qt.resolvedUrl("ui/Accounts.qml") : Qt.resolvedUrl("ui/LoginPage.qml")
        //primaryPageSource: accountSettings.credentialsVerfied ? Qt.resolvedUrl("ui/Accounts.qml") : accounts.choose()
        //primaryPageSource: Qt.resolvedUrl("ui/Accounts.qml"):

        /*
        Component.onCompleted: {
            if(!accountSettings.credentialsVerfied){
                console.log("Login")
                apl.addPageToCurrentColumn(apl.primaryPage, Qt.resolvedUrl("ui/LoginPage.qml"))
            }

        }
        */


        layouts: PageColumnsLayout {
            when: width > units.gu(apl.maxWidth) && accountSettings.credentialsVerfied

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
