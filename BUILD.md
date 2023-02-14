# Build Instructions


## Package Build

```bash
$ PKG_PATH=PATH_TO_UBSYNC
$ 
$ cd ${PKG_PATH}
$ clickable clean --arch arm64
$ clickable build --arch arm64
$
$ clickable clean --arch armhf
$ clickable build --arch armhf
$
$ clickable clean --arch amd64
$ clickable build --arch amd64
$
$ # work with the packages ...
$ touch ${PKG_PATH}/build/aarch64-linux-gnu/app/ubsync_0.5_arm64.click
$ touch ${PKG_PATH}/build/build/arm-linux-gnueabihf/app/ubsync_0.5_armhf.click
$
```


## owncloudcmd build

This step is applicable when new binaries ar required: e.g when deploying version for a new architecture, or new OS version, or in case of issue with current binary version.

The owncloudcmd binary and libraries for 20.04 (focal) were extracted from ubuntu packages @ http://ports.ubuntu.com/ubuntu-ports/ubuntu-ports/pool/universe/o/owncloud-client/

To build binaries from source, the command sequence similar to that presented below could be used:

```bash
$ PKG_PATH=PATH_TO_UBSYNC
$ # ARCH_TRIPLET="arm-linux-gnueabihf"
$ ARCH_TRIPLET="aarch64-linux-gnu"
$
$ wget https://github.com/owncloud/client/archive/v2.5.3.zip
$ unzip v2.5.3.zip
$ cd client-2.5.3
$ BUILD_PATH=$( pwd )
$ 
$ mkdir client-build
$ cd  client-build
$ 
$ cmake -DCMAKE_BUILD_TYPE="release" -DENABLE_GUI="OFF" ..
$ make
$ 
$ cp -a ${BUILD_PATH}/client-build/bin/owncloudcmd ${PKG_PATH}/lib/${ARCH_TRIPLET}/bin
$ cp -a ${BUILD_PATH}/client-build/src/csync/libowncloud_csync.so* ${PKG_PATH}/lib/${ARCH_TRIPLET}/lib/
$ cp -a ${BUILD_PATH}/client-build/src/libsync/libowncloudsync.so* ${PKG_PATH}/lib/${ARCH_TRIPLET}/lib/
$
```
