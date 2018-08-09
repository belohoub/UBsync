import QtQuick 2.4
import Ubuntu.Components 1.3

Item{
    id: status

    property alias status: statusLabel.text
    property alias spinner: activity.running
    property alias button: button
    property var targetHeight: units.gu(6)
    property bool autoHide
    property bool showButton: false

    signal buttonClicked()

    visible: false

    width: parent.width
    //height: 0

    onHeightChanged: {
        if(height === units.gu(0.5)){
            console.log("PopupStatusBox.qml - hide")
            statusLabel.text = ""
            status.visible = false
        }
    }

    function show(){
        status.visible = true
        status.height = targetHeight

        if(autoHide)
        statusTimer.start()
    }

    function hide(){
        status.height = units.gu(0.5)

    }

    Behavior on height {
        NumberAnimation {
            duration: 250;
            easing.type: Easing.OutQuad
        }
    }


    Timer{
        id: statusTimer
        interval: 3500
        onTriggered: hide()
    }

    Rectangle{
        anchors.fill: parent
        color: UbuntuColors.warmGrey

        ActivityIndicator {
            id: activity
            width: parent.height * 0.5
            height: width
            anchors{left: parent.left; verticalCenter: parent.verticalCenter; margins: units.gu(2)}
        }

        Icon{
            id: icon
            visible: !activity.running
            color: "white"
            name: "dialog-warning-symbolic"
            width: parent.height * 0.5
            height: width
            anchors{left: parent.left; verticalCenter: parent.verticalCenter; margins: units.gu(2)}
        }

        Label {
            id:statusLabel
            anchors { left: activity.right; verticalCenter: parent.verticalCenter; leftMargin: units.gu(2)}
            //fontSize: "large"
            color: "white"
            onTextChanged: show()
        }

        Button{
            id: button
            visible: showButton
            anchors { verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: units.gu(2)}
            onClicked: buttonClicked()
        }

    }

}
