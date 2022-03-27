import QtQuick 2.4
import Ubuntu.Components 1.3

Page {
    id: helpPage

    header: PageHeader {
        title: i18n.tr("Help")
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
        contentHeight: dataColumn.height + units.gu(10) + dataColumn.anchors.topMargin + targetNameAccountDisabled.y + targetNameAccountDisabled.height

    Grid {
        id: dataColumn

        spacing: units.gu(1.5)
        anchors {
            top: parent.top; left: parent.left; right: parent.right; topMargin: units.gu(2); rightMargin:units.gu(2); leftMargin: units.gu(2)
        }

        Label {
            id: introDescription
            text: "<p>" +
                  i18n.tr("To set-up synchronization for your folders:") + "</p><br><p>" +
                  i18n.tr("1) go to UBsync \"Online Accounts\", add new account by clicking \"plus\" icon in the main menu") + "</p><br><p>" +
                  i18n.tr("2) set-up new \"target\" by clicking  \"new target\" icon in the account detail page main menu, or in the accounts list accounts' trailer menu") + "</p><br><p>" +
                  i18n.tr("3) start the synchronization service from the \"UBsync Settings\"") +
                  "</p>"
            anchors.leftMargin: units.gu(2)
            font.pixelSize: units.gu(2)
            width: parent.width - parent.anchors.leftMargin - parent.anchors.rightMargin
            wrapMode: Text.WordWrap
        }


        Label {
            id: accountHeader
            text: i18n.tr("Accounts")
            anchors.topMargin: units.gu(3)
            anchors.leftMargin: units.gu(1)
            anchors.top: introDescription.bottom
            font.pixelSize: units.gu(3)
        }

        Label {
            id: accountDescription
            text: "<p>" +
                  i18n.tr("The term \"account\" represents in the UBsync context the system online account, as configured in system settings plus the custom UBsync configuration maintained by UBsync.") + "</p><br><p>" +
                  i18n.tr("The account might be enabled or disabled independently on UBsync. If an account cannot be used by UBsync anymore, its configuration persists in UBsync, however, the related targets will not synchronize.") + "</p><br><p>" +
                  i18n.tr("If you remove the account configuration from UBsync, the related targets will NOT synchronize until you re-create the account settings. If you wish to temporarily pause all targets related to the particular account, you can disable this account in system settings temporarily without affecting UBsync configuration.") +
                  "</p><br><p>" +
                  i18n.tr("UBsync uses following account symbols to express account states:") +
                  "</p>"
            anchors.leftMargin: units.gu(2)
            font.pixelSize: units.gu(2)
            width: parent.width - parent.anchors.leftMargin - parent.anchors.rightMargin
            wrapMode: Text.WordWrap
            anchors {
                topMargin: units.gu(3)
                top: accountHeader.bottom
            }
        }

        Rectangle {
            id: accountSymbol
            color: owncloud.settings.color_accountEnabled
            width: units.gu(6)
            height: units.gu(6)
            border.width: 0
            radius: units.gu(0.9)
            anchors {
                topMargin: units.gu(2.5)
                top: accountDescription.bottom
            }
        }

        Label {
            id: accountSymbolText
            text: "E"
            color: "white"
            font.pixelSize: units.gu(4)
            anchors {
               horizontalCenter: accountSymbol.horizontalCenter; verticalCenter: accountSymbol.verticalCenter
            }
        }


        Label {
            id: accountName
            text: i18n.tr("Enabled Account") + "<br>(" + i18n.tr("related targets will sync") + ")"
            font.pixelSize: units.gu(2)
            wrapMode: Text.WordWrap
            anchors {
               left: accountSymbol.right
               leftMargin: units.gu(2)
               verticalCenter: accountSymbol.verticalCenter
               right: parent.right
            }
        }

        Rectangle {
            id: accountSymbolNotConfigured
            color: owncloud.settings.color_accountEnabledNotConfigured
            width: units.gu(6)
            height: units.gu(6)
            border.width: 0
            radius: units.gu(0.9)
            anchors {
                topMargin: units.gu(2.5)
                top: accountName.bottom
            }
        }

        Label {
            id: accountSymbolNotConfiguredText
            text: "N"
            color: "white"
            font.pixelSize: units.gu(4)
            anchors {
               horizontalCenter: accountSymbolNotConfigured.horizontalCenter; verticalCenter: accountSymbolNotConfigured.verticalCenter
            }
        }


        Label {
            id: accountSymbolNotConfiguredName
            text: i18n.tr("Not Configured Account") + "<br>(" + i18n.tr("related targets will NOT sync") + ")"
            font.pixelSize: units.gu(2)
            anchors {
               left: accountSymbolNotConfigured.right
               leftMargin: units.gu(2)
               verticalCenter: accountSymbolNotConfigured.verticalCenter
               right: parent.right
            }
        }

        Rectangle {
            id: accountSymbolDisabled
            color: owncloud.settings.color_accountDisabled
            width: units.gu(6)
            height: units.gu(6)
            border.width: 0
            radius: units.gu(0.9)
            anchors {
                topMargin: units.gu(2.5)
                top: accountSymbolNotConfigured.bottom
            }
        }

        Text {
            id: accountSymbolDisabledText
            text: "D"
            color: "white"
            font.pixelSize: units.gu(4)
            anchors {
               horizontalCenter: accountSymbolDisabled.horizontalCenter; verticalCenter: accountSymbolDisabled.verticalCenter
            }
        }


        Label {
            id: accountDisabledName
            text: i18n.tr("Disabled Account")  + "<br>(" + i18n.tr("related targets will NOT sync") + ")"
            width: parent.width - parent.anchors.leftMargin - parent.anchors.rightMargin - units.gu(11)
            wrapMode: Text.WordWrap
            font.pixelSize: units.gu(2)
            anchors {
               left: accountSymbolDisabled.right
               leftMargin: units.gu(2)
               verticalCenter: accountSymbolDisabled.verticalCenter
               right: parent.right
            }
        }


        Label {
            id: targetHeader
            text: i18n.tr("Targets")
            anchors.leftMargin: units.gu(1)
            font.pixelSize: units.gu(3)
            anchors {
                top: accountDisabledName.bottom
                topMargin: units.gu(6)
            }
        }

        Label {
            id: targetDescription
            text: "<p>" + i18n.tr("The term \"target\" represents in the UBsync context the remote/local directory pair intended for synchronization plus  the set of custom \"target\" configuration.") + "</p><br>" +
                  "<p>" + i18n.tr("UBsync uses following target symbols to express target states:") + "</p>"
            font.pixelSize: units.gu(2)
            width: parent.width - parent.anchors.leftMargin - parent.anchors.rightMargin
            wrapMode: Text.WordWrap
            anchors {
                topMargin: units.gu(3)
                top: targetHeader.bottom
                left: parent.left;
            }
        }

        Rectangle {
            id: targetSymbol
            color: owncloud.settings.color_targetActive
            width: units.gu(6)
            height: units.gu(6)
            border.width: 0
            radius: units.gu(0.9)
            anchors {
               topMargin: units.gu(2.5)
               top: targetDescription.bottom
            }
        }

        Label {
            id: targetSymbolText
            text: "A"
            color: "white"
            font.pixelSize: units.gu(4)
            anchors {
               horizontalCenter: targetSymbol.horizontalCenter; verticalCenter: targetSymbol.verticalCenter
            }
        }


        Label {
            id: targetName
            text: i18n.tr("Active Target")  + "<br>(" + i18n.tr("target will sync") + ")"
            anchors.leftMargin: units.gu(2)
            font.pixelSize: units.gu(2)
            width: parent.width - parent.anchors.leftMargin - parent.anchors.rightMargin - units.gu(11)
            wrapMode: Text.WordWrap
            anchors {
               left: targetSymbol.right; verticalCenter: targetSymbol.verticalCenter
            }
        }

        Rectangle {
            id: targetSymbolInactive
            color: owncloud.settings.color_targetInactive
            width: units.gu(6)
            height: units.gu(6)
            border.width: 0
            radius: units.gu(0.9)
            anchors {
               topMargin: units.gu(2.5)
               top: targetSymbol.bottom
            }
        }

        Label {
            id: targetSymbolInactiveText
            text: "I"
            color: "white"
            font.pixelSize: units.gu(4)
            anchors {
               horizontalCenter: targetSymbolInactive.horizontalCenter; verticalCenter: targetSymbolInactive.verticalCenter
            }
        }


        Label {
            id: targetNameInactive
            text: i18n.tr("Inactive Target") + "<br>(" + i18n.tr("target will NOT sync") + ")"
            anchors.leftMargin: units.gu(2)
            font.pixelSize: units.gu(2)
            width: parent.width - parent.anchors.leftMargin - parent.anchors.rightMargin  - units.gu(11)
            wrapMode: Text.WordWrap
            anchors {
               left: targetSymbolInactive.right; verticalCenter: targetSymbolInactive.verticalCenter
            }
        }


        Rectangle {
            id: targetSymbolAccountDisabled
            color: owncloud.settings.color_targetAccountDisabled
            width: units.gu(6)
            height: units.gu(6)
            border.width: 0
            radius: units.gu(0.9)
            anchors {
               topMargin: units.gu(2.5)
               top: targetSymbolInactive.bottom
            }
        }

        Label {
            id: targetSymbolAccountDisabledText
            text: "T"
            color: "white"
            font.pixelSize: units.gu(4)
            anchors {
               horizontalCenter: targetSymbolAccountDisabled.horizontalCenter; verticalCenter: targetSymbolAccountDisabled.verticalCenter
            }
        }


        Label {
            id: targetNameAccountDisabled
            text: i18n.tr("Target With Disabled/Not Configured Account") + "<br>(" + i18n.tr("target will NOT sync") + ")"
            anchors.leftMargin: units.gu(2)
            font.pixelSize: units.gu(2)
            width: parent.width - parent.anchors.leftMargin - parent.anchors.rightMargin - units.gu(11)
            wrapMode: Text.WordWrap
            anchors {
               left: targetSymbolAccountDisabled.right; verticalCenter: targetSymbolAccountDisabled.verticalCenter
            }
        }

    }

    }
}
