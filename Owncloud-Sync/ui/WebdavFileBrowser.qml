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

    WebdavFolderListModel{
        id: folderListModel

        showDirs:  true
        showFiles: false
        showHidden: false

        username: owncloud.settings.username
        password: owncloud.settings.password
        serverUrl:owncloud.settings.serverURL

        //folder must be set after the credenials are set - TO DO: Allow folder to be called any where.
        folder: caller.text ? caller.text : fileBrowser.rootPath

        onFolderChanged: {
            connectionStatus.spinner = true
            connectionStatus.status = i18n.tr("Loading")
        }
        onCountChanged: {
            connectionStatus.hide()
            fileBrowser.showNoChildFolders = true
        }

        function newFolder(folderPath){
            console.log(folderPath)
            //newFolder(folderPath)

            folderListModel.newWebDavFolder(folderPath)

        }
    }

    PopupStatusBox{
        id: connectionStatus
        autoHide: false
        anchors{left: parent.left; right:parent.right; bottom: parent.bottom;}

    }
}


