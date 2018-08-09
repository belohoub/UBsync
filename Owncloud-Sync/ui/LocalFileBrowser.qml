import QtQuick 2.4
import Ubuntu.Components 1.3
import Qt.labs.folderlistmodel 2.1

import "../components"

FileBrowser{
    id:fileBrowser
    folderModel: folderListModel
    caller: caller
    rootPath: Qt.resolvedUrl(owncloudsync.homePath())
    showNoChildFolders: true
    //property var caller

    FolderListModel {
        id: folderListModel
        showFiles: false
        //showHidden: true
        folder: caller.text ? caller.text : fileBrowser.rootPath


        function newFolder(folderPath){
            console.log(folderPath)
            owncloudsync.newFolder(folderPath)

        }
    }
}
