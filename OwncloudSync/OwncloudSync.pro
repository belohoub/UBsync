TEMPLATE = lib
TARGET = OwncloudSync
QT += qml quick dbus xml network
CONFIG += qt plugin c++11

load(ubuntu-click)

TARGET = $$qtLibraryTarget($$TARGET)

# Input
SOURCES += \
    backend.cpp \
    servicecontrol.cpp \
    daemoncontroller.cpp \
    owncloudsync.cpp \
    webdavfolderlistmodel.cpp

HEADERS += \
    backend.h \
    servicecontrol.h \
    daemoncontroller.h \
    owncloudsync.h \
    webdavfolderlistmodel.h

OTHER_FILES = qmldir

!equals(_PRO_FILE_PWD_, $$OUT_PWD) {
    copy_qmldir.target = $$OUT_PWD/qmldir
    copy_qmldir.depends = $$_PRO_FILE_PWD_/qmldir
    copy_qmldir.commands = $(COPY_FILE) \"$$replace(copy_qmldir.depends, /, $$QMAKE_DIR_SEP)\" \"$$replace(copy_qmldir.target, /, $$QMAKE_DIR_SEP)\"
    QMAKE_EXTRA_TARGETS += copy_qmldir
    PRE_TARGETDEPS += $$copy_qmldir.target
}

qmldir.files = qmldir
installPath = $$OUT_PWD/OwncloudSync
qmldir.path = $$installPath
target.path = $$installPath
INSTALLS += target qmldir

INCLUDEPATH += $$PWD/../qwebdavlib
DEPENDPATH += $$PWD/../qwebdavlib

#LIBS += -L$$OUT_PWD/../qwebdavlib/ -lqwebdav
LIBS += -L$$OUT_PWD/../qwebdavlib/ -lqwebdav
