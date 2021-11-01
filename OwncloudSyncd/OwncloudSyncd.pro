QT += core sql network dbus xml
QT -= gui

TARGET = OwncloudSyncd
CONFIG += console
CONFIG -= app_bundle

INCLUDEPATH += /usr/include/accounts-qt5
INCLUDEPATH += /usr/include/signon-qt5

load(ubuntu-click)

TEMPLATE = app

SOURCES += main.cpp \
    owncloudsyncd.cpp

HEADERS += \
    owncloudsyncd.h

# Default rules for deployment.
target.path = $${UBUNTU_CLICK_BINARY_PATH}
INSTALLS+=target

LIBS += -laccounts-qt5
LIBS += -lsignon-qt5

#unix: CONFIG += link_pkgconfig
#unix: PKGCONFIG += accounts-qt5
