import QtQuick 2.4
import Ubuntu.Components 1.3
import Ubuntu.Components.Popups 1.0
import Ubuntu.Content 1.3

Page {
    id: pickerPage
    visible: true
    property var transferItems
    title: i18n.tr("Share")

    header: PageHeader {
        id: header
        title: pickerPage.title
    }


    function getTransferList(){
    var array = []
        for(var i = 0; i < transferItems.length; i++){
            console.log( pickerPage.transferItems[i])
            array .push(resultComponent.createObject(pickerPage, {"url": pickerPage.transferItems[i]}))
        }

        return array
    }


    Component {
        id: resultComponent
        ContentItem {}
    }

    Item {
        anchors{top: header.bottom; bottom: parent.bottom; left:parent.left; right:parent.right}

        ContentPeerPicker {
            id: peerPicker
            showTitle : false

            visible: parent.visible
            contentType: ContentType.All
            handler: ContentHandler.Share

            onCancelPressed: {
                apl.removePages(pickerPage)
            }

            onPeerSelected: {
                print ("onPeerSelected: " + peer.name);
                print ("sending files: " + pickerPage.transferItems);

                var request = peer.request();
                request.items = getTransferList();
                request.state = ContentTransfer.Charged;

                apl.removePages(pickerPage)

            }
        }
    }
}
