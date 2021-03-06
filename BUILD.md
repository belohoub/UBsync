# Build owncloudcmd

The owncloudcmd and libraries for the 64-bit version were build following the command sequence below, the 32-bit version uses the original binaries from the previous builds:

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
$ cp -a ${BUILD_PATH}/client-build/bin/owncloudcmd ${PKG_PATH}/Owncloud-Sync/lib/${ARCH_TRIPLET}/bin
$ cp -a ${BUILD_PATH}/client-build/src/csync/libowncloud_csync.so* ${PKG_PATH}/Owncloud-Sync/lib/${ARCH_TRIPLET}/lib/
$ cp -a ${BUILD_PATH}/client-build/src/libsync/libowncloudsync.so* ${PKG_PATH}/Owncloud-Sync/lib/${ARCH_TRIPLET}/lib/
$
```

# Build Package

```bash
$ PKG_PATH=PATH_TO_UBSYNC
$ 
$ cd ${PKG_PATH}
$ clickable --arch arm64
$ clickable --arch armhf
$
$ # work with the packages ...
$ touch ${PKG_PATH}/build/aarch64-linux-gnu/app/ubsync_0.5_arm64.click
$ touch ${PKG_PATH}/build/build/arm-linux-gnueabihf/app/ubsync_0.5_armhf.click
$
```
