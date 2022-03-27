import QtQuick 2.4
import Ubuntu.Components 1.3
import "../components"

Page {
    id: aboutPage

   // property string daemonVersion: ""

    header: PageHeader {
        title: i18n.tr("About")
        flickable: flickable
    }

    Timer {
        id: continuousCheck
        interval: 50
        running: true
        repeat: true
        onTriggered: {
            // hide back navigation in double-column mode
            if (apl.columns === 1) {
                header.navigationActions[0].visible = true
            } else {
                header.navigationActions[0].visible = false
            }
        }
    }

    Flickable {
        id: flickable

        flickableDirection: Flickable.AutoFlickIfNeeded
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
                    onClicked: {
                        /* TODO: The share debug feature was here; any other hiddent feature could be activated in the future :-)*/
                    }
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
                    id: appVersionLabel
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    // TRANSLATORS: Owncloud Sync version number e.g Version 0.1
                    text: i18n.tr("App Version %1").arg(Qt.application.version)
                }
                Label{
                    id: clientLabel
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    // TRANSLATORS: Nextcloudcmd binary version number e.g Version 1.8.1
                    text: i18n.tr("Client: %1").arg(owncloud.settings.owncloudcmdVersion)
                }
                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: " "
                }
                LabelLinkRow {
                    id: maintainerLabel
                    //width: parent.width
                    anchors{
                        horizontalCenter: clientLabel.horizontalCenter
                    }
                    // TRANSLATORS: %1 is the maintainers name, %2 is the link text to the UBsync contributors teams page
                    labeltext: i18n.tr("Maintained by %1 and the").arg("Jan")
                    linktext: i18n.tr("UBsync team")
                    linkurl: "https://github.com/belohoub/UBsync#current-and-past-contributors"
                }
                Label {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    text: " "
                }
                LabelLinkRow {
                    id: issueReportLabel
                    //width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    labeltext: i18n.tr("Please report bugs to the")
                    linktext: i18n.tr("issue tracker")
                    linkurl: "https://github.com/belohoub/UBsync/issues"
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
                    text: i18n.tr("Thanks to")
                }

                LabelLinkRow {
                    id: ownCloudClientLabel
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    labeltext: i18n.tr("Owncloud client:")
                    linktext: "Owncloudcmd"
                    linkurl: "https://doc.owncloud.org/desktop/2.3/owncloudcmd.1.html"
                }
                LabelLinkRow {
                    id: nextCloudClientLabel
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    labeltext: i18n.tr("Nextcloud client:")
                    linktext: "Nextcloudcmd"
                    linkurl: "https://docs.nextcloud.com/desktop/2.3/advancedusage.html"
                }
                LabelLinkRow {
                    id: qtLabel
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    labeltext: i18n.tr("This Qt library for WebDAV:")
                    linktext: "qwebdavlib"
                    linkurl: "https://github.com/mhaller/qwebdavlib"
                }
                LabelLinkRow {
                    id: iconLabel
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    labeltext: i18n.tr("Joan CiberSheep for the logo from:")
                    linktext: "Suru Theme"
                    linkurl: "https://github.com/snwh/suru-icon-theme"
                }
                LabelLinkRow {
                    id: clickableLabel
                    width: parent.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    labeltext: i18n.tr("Lukas to enable the application with:")
                    linktext: "Clickable"
                    linkurl: "https://clickable-ut.dev/en/latest/index.html"
                }
            }
            Label {
                textSize: Label.Small
                width: parent.width
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                text: i18n.tr("Released under the terms of the GNU GPL v3")
            }
            LabelLinkRow {
                id: forkLabel
                //width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                labeltext: i18n.tr("Fork of:")
                linktext: "Owncloud-Sync"
                linkurl: "https://launchpad.net/owncloud-sync"
            }
            LabelLinkRow {
                id: sourceCodeLabel
                //width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                labeltext: i18n.tr("Source code available on:")
                linktext: "github.com/belohoub/UBsync"
                linkurl: "https://github.com/belohoub/UBsync"
            }
        }
    }
}
