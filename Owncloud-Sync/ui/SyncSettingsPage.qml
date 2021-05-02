import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3
import Ubuntu.Components.Pickers 1.0

import Qt.labs.folderlistmodel 2.1
import QtQuick.LocalStorage 2.0

import "../components"

Page {
    id: syncSettings
    //property string syncFolders
    property var db
    header: PageHeader {
        id: syncHeader
        title: i18n.tr("Sync Settings")

        trailingActionBar {
            actions: [
                Action {
                    iconName: "add"
                    text: i18n.tr("Add")
                    onTriggered: {
                        folderListModel.append({"local":"", "remote":""})
                        syncSettings.addToDB();
                        syncSettings.loadDB();

                    }
                }
            ]
        }
    }

    ListModel{
        id: folderListModel
        Component.onCompleted: {
            syncSettings.loadDB()
        }
    }

    //////////////////////////////////////////////////////////////////////////////
    ///////////////////////////// Database Functions /////////////////////////////
    //////////////////////////////////////////////////////////////////////////////

    function loadDB() {

        folderListModel.clear();

        syncSettings.db = LocalStorage.openDatabaseSync("UBsync", "1.0", "UBsync folders", 1000000);

        syncSettings.db.transaction(
                    function(tx) {
                        // Create the database if it doesn't already exist
                        tx.executeSql('CREATE TABLE IF NOT EXISTS SyncFolders(id INTEGER PRIMARY KEY AUTOINCREMENT, local TEXT, remote TEXT)');
                        // load all folder paths
                        var rs = tx.executeSql('SELECT * FROM SyncFolders');

                        console.log("[SyncSettingsPage - loadDB] - Database Open. Contains " + rs.rows.length + " rows.")
                        for(var i = 0; i < rs.rows.length; i++) {
                            //console.log("Append to folderlistmodel: " + rs.rows.item(i).id + " " + rs.rows.item(i).local + " " + rs.rows.item(i).remote)
                            folderListModel.append({"id":rs.rows.item(i).id, "local":rs.rows.item(i).local, "remote":rs.rows.item(i).remote})

                        }
                    }
                    )
    }

    function addToDB(){
        console.log("Create database entry in Syncfolders table");
        syncSettings.db.transaction(
                    function(tx) {
                        // Create the database if it doesn't already exist
                        tx.executeSql('INSERT INTO SyncFolders VALUES(NULL, "", "")');
                    }
                    )
    }

    function deleteFromDB(index){
        console.log("Delete database entry from row " + index);
        syncSettings.db.transaction(
                    function(tx) {
                        // Delete the selected entry
                        tx.executeSql('DELETE FROM SyncFolders WHERE id = (?)', [folderListModel.get(index).id]);
                    }
                    )
    }

    function updateDB(index){
        //console.log("Update entry on row " + (Number(rowID)+1));
        syncSettings.db.transaction(
                    function(tx) {
                        //console.log("update ID" + folderListModel.get(index).id)
                        tx.executeSql('UPDATE SyncFolders SET local=(?), remote=(?) WHERE id = (?)',[ folderListModel.get(index).local,
                                                                                                     folderListModel.get(index).remote,
                                                                                                     folderListModel.get(index).id]);
                    }
                    )
    }


    Item{
        //Shown if there are no sync items in the database
        anchors{centerIn: parent}

        
        
        Label{
            visible: !folderListModel.count
            text: i18n.tr("No folders, press")
            anchors{horizontalCenter: parent.horizontalCenter; bottom: addIcon.top; bottomMargin: units.gu(2)}
        }
        
        Icon {
            id: addIcon
            visible: !folderListModel.count
            name: "add"
            width: units.gu(4)
            height: width
            anchors{centerIn: parent}
        }

        Label{
            visible: !folderListModel.count
            text: i18n.tr("on the panel to add a new folder")
            anchors{horizontalCenter: parent.horizontalCenter; top: addIcon.bottom; topMargin: units.gu(2)}
        }
    }

    ListView {
        id: syncList
        visible: folderListModel.count
        anchors{left:parent.left; right:parent.right; top:syncHeader.bottom; bottom:parent.bottom; bottomMargin:units.gu(2)}
        clip: true
        model: folderListModel

        delegate: ListItem {
            height: syncDirColumn.height + (syncDirColumn.spacing * 4)+ divider.height
            anchors{left:parent.left; right:parent.right}

            Column{
                id: syncDirColumn

                spacing: units.gu(1)
                anchors {
                    top: parent.top; left: parent.left; right: parent.right; margins:units.gu(2)
                }

                Label{
                    id: localLabel
                    visible: folderListModel.count
                    text: i18n.tr("Local Folder:")
                }

                Button {
                    id: localText
                    text: folderListModel.get(index) ? folderListModel.get(index).local : ""
                    width: parent.width
                    color: UbuntuColors.porcelain
                    onTextChanged: {
                        if(index > -1){
                            folderListModel.setProperty(index, "local", text);
                            syncSettings.updateDB(index);
                        }
                    }
                    onClicked: apl.addPageToNextColumn(syncSettings, Qt.resolvedUrl("LocalFileBrowser.qml"), {caller:localText})
                }

                Label{
                    id: remoteLabel
                    visible: folderListModel.count
                    text: i18n.tr("Remote Folder:")
                }

                Button {
                    id: remoteText
                    text: folderListModel.get(index) ? folderListModel.get(index).remote : ""
                    width: parent.width
                    color: UbuntuColors.porcelain
                    onTextChanged: {
                        if(index > -1){
                            folderListModel.setProperty(index, "remote", text)
                            syncSettings.updateDB(index);
                        }
                    }
                    onClicked: {

                        if(!owncloudsync.networkAvailable){
                            connectionStatus.status = i18n.tr("No Network Available")
                            connectionStatus.indicationIcon = "offline"
                         }else{

                        apl.addPageToNextColumn(syncSettings, Qt.resolvedUrl("WebdavFileBrowser.qml"), {caller:remoteText})
                        }
                    }
                }
            }


            leadingActions: ListItemActions {
                actions: [
                    Action {
                        iconName: "delete"
                        onTriggered: {
                            console.log("Delete Action: Remove folderListModel index " + index)
                            console.log("Delete From Database with id:" + folderListModel.get(index).id)
                            syncSettings.deleteFromDB(index);
                            folderListModel.remove(index, 1);
                        }
                    }
                ]
            }
        }
    }

    PopupStatusBox{
        id: connectionStatus
        autoHide: true
        anchors{left: parent.left; right:parent.right; bottom: parent.bottom;}

    }
}
