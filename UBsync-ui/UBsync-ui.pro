TEMPLATE = aux
TARGET = UBsync-ui

RESOURCES += UBsync-ui.qrc

QML_FILES += $$files(*.qml,true) \
             $$files(*.js,true)

CONF_FILES +=  UBsync.apparmor \
               UBsync.accounts \
               UBsync.png

AP_TEST_FILES += tests/autopilot/run \
                 $$files(tests/*.py,true)

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               $${AP_TEST_FILES} \
               UBsync.desktop


#specify where the qml/js files are installed to
qml_files.path = /UBsync-ui
qml_files.files += *.qml #$${QML_FILES}

#specify where the ui qml/js files are installed to
ui_files.path = /UBsync-ui/ui
ui_files.files += ui/*.qml ui/*.js

#specify where the component qml/js files are installed to
component_files.path = /UBsync-ui/components
component_files.files += components/*.qml

#specify where the config files are installed to
config_files.path = /UBsync-ui
config_files.files += $${CONF_FILES}

owncloud_files.path = /lib/
owncloud_files.files += aarch64-linux-gnu/bin/*
owncloud_files.files += aarch64-linux-gnu/lib/*
owncloud_files.files += arm-linux-gnueabihf/bin/*
owncloud_files.files += arm-linux-gnueabihf/lib/*

#install the desktop file, a translated version is
#automatically created in the build directory
desktop_file.path = /UBsync-ui
desktop_file.files = $$OUT_PWD/UBsync.desktop
desktop_file.CONFIG += no_check_exist

INSTALLS+=config_files qml_files desktop_file owncloud_files ui_files component_files

DISTFILES += \
    ui/AboutPage.qml \
    ui/AccountsPage.qml \
    ui/EditAccount \
    ui/EditTarget \
    ui/webdav.js \
    ui/WebdavFileBrowser.qml \
    ui/LocalFileBrowser.qml \
    components/PopupStatusBox.qml \
    ui/SyncServicePage.qml \
    ui/TargetsPage.qml \
    components/FileBrowser.qml \
