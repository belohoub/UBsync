import QtQuick 2.4
import Ubuntu.Components 1.3

import "../components"

// C++ Plugin
import OwncloudSync 1.0

FileBrowser{
    id:fileBrowser
    caller: caller
    folderModel: folderListModel
    rootPath: "/"

    property string paramUsername: ""
    property string paramPassword: ""
    property string paramServerUrl: ""

    WebdavFolderListModel{
        id: folderListModel

        showDirs:  true
        showFiles: false
        showHidden: true

        username: fileBrowser.paramUsername
        password: fileBrowser.paramPassword
        serverUrl: fileBrowser.paramServerUrl

        folder: caller.text ? caller.text : fileBrowser.rootPath

        onFolderChanged: {
            connectionStatus.spinner = true
            connectionStatus.status = i18n.tr("Loading")
            connectionStatus.indicationIcon = "updating"
        }
        onCountChanged: {
            connectionStatus.hide()
            fileBrowser.showNoChildFolders = true
        }

        function newFolder(folderPath){
            console.log(folderPath)

            folderListModel.newWebDavFolder(folderPath)

        }
    }

    PopupStatusBox{
        id: connectionStatus
        autoHide: false
        anchors{left: parent.left; right:parent.right; bottom: parent.bottom;}

    }
}


