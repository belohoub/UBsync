import QtQuick 2.4
import Ubuntu.Components 1.3

Item{
    id: status

    property alias status: statusLabel.text
    property alias spinner: activity.running
    property alias button: button
    property alias statusTimer: statusTimer
    property var targetHeight: units.gu(6)
    property bool autoHide
    property bool showButton: false
    property string indicationIcon: "idle" /* error, idle, offline, paused, updating */
    
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

         if(autoHide) {
             console.log("PopupStatusBox.qml - autoHide")
             //statusTimer.start();
             statusTimer.startTimer(hide, 3500);
         } else {
             console.log("PopupStatusBox.qml - NO autoHide")
         }
    }

    function hide() {
        status.height = units.gu(0.5)

    }

    Behavior on height {
        NumberAnimation {
            duration: 250;
            easing.type: Easing.OutQuad
        }
    }


    Timer {
        id: statusTimer
        
        // Start the timer and execute the provided callback on every X milliseconds
        function startTimer(callback, milliseconds) {
            statusTimer.interval = milliseconds;
            statusTimer.repeat = false;
            statusTimer.triggered.connect(callback);
            statusTimer.start();
        }
        
        // Stop the timer and unregister the callback
        function stopTimer(callback) {
            statusTimer.stop();
            statusTimer.triggered.disconnect(callback);
        }
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
            name: "sync-" + indicationIcon
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
