import QtQuick 2.4
import Lomiri.Components 1.3

Row {
    property string labeltext
    property string linktext
    property string linkurl

    spacing: units.gu(1)
    anchors.horizontalCenter: parent.horizontalCenter

    Label {
        id: label
        text: labeltext
        wrapMode: Text.WordWrap
    }
    Label {
        id: linklabel
        text: linktext
        wrapMode: Text.WordWrap
        color: theme.palette.normal.activity
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.openUrlExternally(linkurl)
        }
    }
}
