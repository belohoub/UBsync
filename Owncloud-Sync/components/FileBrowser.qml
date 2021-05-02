import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.3


Page {
    id: fileBrowser
    property alias folderModel: folderList.model
    property alias folderListView: folderList
    property string currentPath: folderListModel.folder
    property string rootPath
    property var caller
    property bool showNoChildFolders: false

    header: PageHeader {
        id: fileBrowserHeader
        title: currentPath.replace("file://", "")

        leadingActionBar.actions: [
            Action {
                visible: currentPath !== rootPath
                iconName: "back"
                onTriggered: {
                    console.log("FileBrowser.qml - back button pressed")
                    if(currentPath.lastIndexOf("/") === 0){
                        folderListModel.folder = rootPath;
                    }else{
                        folderListModel.folder = currentPath.slice(0, currentPath.lastIndexOf("/"))
                    }
                }
            }
        ]

        trailingActionBar{
            actions: [
                Action {
                    iconName: "tick"
                    onTriggered: {
                        caller.text = currentPath.replace("file://", "");
                        apl.removePages(fileBrowser)
                    }
                },

                Action {
                    iconName: "close"
                    onTriggered: {apl.removePages(fileBrowser)}
                },

                Action {
                    iconName: "add"
                    onTriggered: PopupUtils.open(dialog)
                }
            ]
        }
    }


    Item{
        anchors.fill: parent
        //anchors{centerIn: parent}
        visible:!folderListModel.count && showNoChildFolders

        Column{
            anchors{centerIn: parent}
            spacing: units.gu(2)

            Label{
                width: parent.width
                text: i18n.tr("No folders, press")
                horizontalAlignment: Text.AlignHCenter
            }

            Icon {
                id: addIcon
                name: "tick"
                width: units.gu(4)
                height: width
            }

            Label{
                width: parent.width
                text: i18n.tr("on the panel to select this folder")
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }


    ListView {
        id: folderList
        //anchors.fill: parent
        anchors { top: fileBrowserHeader.bottom; left: parent.left; right: parent.right; bottom:parent.bottom}
        clip: true
        //model: folderListModel


        delegate: ListItem {
            height: layout.height + (divider.visible ? divider.height : 0)
            ListItemLayout {
                id: layout
                title.text: model.fileName
                //subtitle.text: model.fileSize
                ProgressionSlot {}

                Icon {
                    name: "document-open"
                    anchors{verticalCenter: parent.verticalCenter}
                    SlotsLayout.position: SlotsLayout.Leading;
                    width: units.gu(3)
                }
            }

            onClicked: {

                var filePath = model.filePath
                if (filePath.slice(-1) === "/"){
                    filePath = filePath.substring(0, filePath.length - 1)
                }
                console.log(folderListModel.count)
                folderListModel.folder = filePath
            }
        }
    }

    Component {
        id: dialog
        Dialog {
            id: dialogue
            title: i18n.tr("Create New Folder")

            TextField {
                id: folderName
                placeholderText: i18n.tr("New Folder")
                hasClearButton: true
                validator: RegExpValidator{ regExp: /^[A-Za-z0-9 _-]*$/ }
                inputMethodHints: Qt.ImhNoPredictiveText
            }

            Button {
                text: i18n.tr("Cancel")
                onClicked: PopupUtils.close(dialogue)
            }
            Button {
                id: okButton
                text: i18n.tr("OK")
                enabled: folderName.text
                color: UbuntuColors.orange
                onClicked: {
                    folderListModel.newFolder(currentPath + "/" + folderName.text)
                    PopupUtils.close(dialogue)
                }
            }
        }
    }


}


