import QtQuick 2.4
import Ubuntu.Components 1.3

Page {
    id: aboutPage
    property int showDebug

   // property string daemonVersion: ""

    header: PageHeader {
        title: i18n.tr("About")
        flickable: flickable
    }

    Flickable {
        id: flickable

        anchors.fill: parent
        contentHeight: dataColumn.height + units.gu(10) + dataColumn.anchors.topMargin

        Column {
            id: dataColumn

            spacing: units.gu(3)
            anchors {
                top: parent.top; left: parent.left; right: parent.right; topMargin: units.gu(5); rightMargin:units.gu(2.5); leftMargin: units.gu(2.5)
            }

            UbuntuShape {
                width: units.gu(20)
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                source: Image {
                   source: "../UBsync.png"
                }

                MouseArea{
                    anchors.fill: parent
                    onClicked: {if(showDebug < 3){showDebug++}}
                }

            }

            Label {
                width: parent.width
                textSize: Label.XLarge
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                text: "UBsync"
            }

            Column {
                width: parent.width

                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    // TRANSLATORS: Owncloud Sync version number e.g Version 0.1
                    text: i18n.tr("App Version %1").arg(Qt.application.version)
                }
                Label{
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    // TRANSLATORS: Nextcloudcmd binary version number e.g Version 1.8.1
                    text: i18n.tr("Client : %1").arg(owncloud.settings.owncloudcmdVersion)
                }
                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr("Maintained by %1").arg("Dan & Ern_st")
                }

                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: i18n.tr(" ")
                }
                 Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    text: i18n.tr("If you are willing to help please look at %1").arg("<a href=\"https://bugs.launchpad.net/owncloud-sync/ubsync/+bugs\">the bug list</a>")
                    onLinkActivated: Qt.openUrlExternally(link)
                 }
            }

            Column {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: units.gu(2)
                }
                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    font.weight: Font.DemiBold
                    horizontalAlignment: Text.AlignHCenter
                    text: "Thanks to"
                }

                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: "Owncloud client: %1".arg("<a href=\"https://doc.owncloud.org/desktop/2.3/owncloudcmd.1.html\">Owncloudcmd</a>")
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: "Nextcloud client: %1".arg("<a href=\"https://docs.nextcloud.com/desktop/2.3/advancedusage.html\">Nextcloudcmd</a>")
                    onLinkActivated: Qt.openUrlExternally(link)
                }


                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: "%1, a Qt library for WebDAV".arg("<a href=\"https://github.com/mhaller/qwebdavlib\">qwebdavlib</a>")
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: "Joan CiberSheep for the %1 logo".arg("<a href=\"https://github.com/snwh/suru-icon-theme\">Suru Theme</a>")
                    onLinkActivated: Qt.openUrlExternally(link)
                }
                Label {
                    width: parent.width
                    wrapMode: Text.WordWrap
                    horizontalAlignment: Text.AlignHCenter
                    text: "Lukas to enable the application with %1".arg("<a href=\"http://clickable.bhdouglass.com/en/latest/index.html\">Clickable</a>")
                    onLinkActivated: Qt.openUrlExternally(link)
                }
            }
            Label {
                textSize: Label.Small
                width: parent.width
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: i18n.tr("Released under the terms of the GNU GPL v3")
            }
            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                textSize: Label.Small
                horizontalAlignment: Text.AlignHCenter
                text: "Fork from %1".arg("<a href=\"https://launchpad.net/owncloud-sync\">Owncloud-Sync</a>")
                onLinkActivated: Qt.openUrlExternally(link)
            }
            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                textSize: Label.Small
                horizontalAlignment: Text.AlignHCenter
                text: i18n.tr("Source code available on %1").arg("<a href=\"https://code.launchpad.net/~ocs-team/owncloud-sync/UBsync\">Owncloud-sync/UBsync</a>")
                onLinkActivated: Qt.openUrlExternally(link)
            }
            Button{
                text: i18n.tr("Share Debug Logs")
                visible: showDebug > 2
                anchors{ horizontalCenter: parent.horizontalCenter }
                onClicked: apl.addPageToNextColumn(apl.primaryPage, Qt.resolvedUrl("SharePage.qml"), {transferItems: owncloudsync.logPath()})
            }
        }
    }
}
