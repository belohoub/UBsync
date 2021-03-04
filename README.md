**This repository is related to the discussion at [forums.ubports.com](https://forums.ubports.com/topic/5116/help-creating-an-ubsync-arm64-version/30) related to missing amr64 support for UBsync**

**This fork needs revision!**

# Project presentation

<img src="https://framagit.org/ernesst/UBsync/raw/master/Owncloud-Sync/UBsync.png" width="196">

UBsync is a forked of [ownCloud-sync](https://launchpad.net/owncloud-sync) dedicated to Nextcloud application for **Ubuntu touch 16.04**,  supported by [Ubports](https://www.ubports.com).

# Multiarch Changelog (03-02-2021)
1. clickable.json added
1. arm64 version of owncloudcmd is 2.5.3; arm32 remains unchanged
1. arch detection and paths to owncloudcmd changed in *OwncloudSyncd/owncloudsyncd.cpp*
1. arch detection and paths for libs added to *OwncloudSync/servicecontrol.cpp*
1. included support for owncloud account in ubuntu-touch (up to now, only nextcloud account was used, even those behave equaly from the UBsync point of view)

# 0.4 Changelog
1. Migrate the source to https://launchpad.net/owncloud-sync
1. Allo to synchronize hidden folder on the phone
1. Add hidden file synchronization
1. Update about.qml

# 0.3 Changelog
1. Compiled for Xenial,
1. Upgraded of owncloudcmd to nextcloudcmd 2.3.3, [Bug 1592538](https://bugs.launchpad.net/owncloud-sync/+bug/1592538)
1. Get ride off the bug "owncloud network access is disabled" - [Bug 1572321](https://bugs.launchpad.net/ubuntu/+source/owncloud-client/+bug/1572321?comments=all),
1. Use of Online Account - [bug 1573802](https://bugs.launchpad.net/owncloud-sync/+bug/1573802), in the hope to get ride off the password in the config file in the future 
1. Change the frequencies from seconds to hours,
1. Acknowledge qWebdavlib - [bug 1592750](https://bugs.launchpad.net/owncloud-sync/+bug/1592750)
1. New icon,

# Thanks 

I would like to thanks several projects / persons 
1. [ownCloud-sync application](https://launchpad.net/owncloud-sync),
1. [Nextcloudcmd](https://docs.nextcloud.com/desktop/2.3/advancedusage.html), a Nextcloud client,
1. [qWebdavlib](https://github.com/mhaller/qwebdavlib) a Qt library for WebDAV,
1. Joan CiberSheep for the icon using [Suru Icon Theme elements](https://github.com/snwh/suru-icon-theme)


# Contribution

Any help on the code is welcomed to enhance the app. 


Ernesst
