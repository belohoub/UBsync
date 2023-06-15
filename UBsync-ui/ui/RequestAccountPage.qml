import QtQuick 2.4
import Lomiri.Components 1.3
import "../components"



Page {
    id: requestAccountsPage


    header: PageHeader {
        id: header
        title: i18n.tr("Add Online Account")

    }

    Item {
        anchors{left:parent.left; right:parent.right; top:header.bottom; bottom:parent.bottom; bottomMargin:units.gu(2)}

        Button{
            id: addOwnCloudButton
            text: i18n.tr("Add Nextcloud account")
            anchors {
                top: parent.top; left: parent.left; right: parent.right; margins: units.gu(2)
            }

            onClicked: {
                console.log("RequestAccountPage :: Add Nextcloud account: clicked")
                apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("AccountsPage.qml"), {requestAccount: "nextcloud"})
            }
        }

        Button{
            id: addNextCloudButton
            text: i18n.tr("Add OwnCloud account")
            anchors {
                top: addOwnCloudButton.bottom; left: parent.left; right: parent.right; margins: units.gu(2)
            }

            onClicked: {
                console.log("RequestAccountPage :: Add OwnCloud account: clicked")
                apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("AccountsPage.qml"), {requestAccount: "owncloud"})
            }
        }

    }

}
