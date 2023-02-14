# Changelog

# 0.7.6 (02/2023)
1. Focal support added
1. New focal-compatible binaries and libs included

# 0.7.5 (04/2022)
1. UI re-designed a bit - new main screen in landscape mode
1. WebDAV browser extension: errors are reported to users
1. Minor fixes
1. Internationalization: German, Spanish, French, Dutch, and Czech localization

# 0.7 (12/2021)
1. directory-tree cleanup
1. database structure altered (see [DATABASE.md](DATABASE.md) for the new structure)
1. multi-account support
1. UI re-designed completely
1. Internationalization: German, Spanish, and Czech localization

# 0.6 (multiarch) (02/2021)
1. clickable.json added
1. arm64 version of owncloudcmd is 2.5.3; arm32 remains unchanged
1. arch detection and paths to owncloudcmd changed in *OwncloudSyncd/owncloudsyncd.cpp*
1. arch detection and paths for libs added to *OwncloudSync/servicecontrol.cpp*
1. included support for owncloud account in Ubuntu Touch (up to now, only nextcloud account was used, even those behave equaly from the UBsync point of view)
1. [build instructions](BUILD.md)

# 0.5 Changelog:
1. Enable clickable thanks to Lukas
1. fix issue with webdav port thanks to Lukas
1. upgrade to owncloudcmd 2.6.0-git
1. cleanup some files

# 0.4 Changelog
1. Migrate the source to https://launchpad.net/owncloud-sync
1. Allo to synchronize hidden folder on the phone
1. Add hidden file synchronization
1. Update about.qml

# 0.3 Changelog
1. Compiled for Xenial,
1. Upgraded of owncloudcmd to nextcloudcmd 2.3.3, [Bug 1592538](https://bugs.launchpad.net/owncloud-sync/+bug/1592538)
1. Get ride off the bug "owncloud network access is disabled" - [Bug 1572321](https://bugs.launchpad.net/ubuntu/+source/owncloud-client/+bug/1572321?comments=all),
1. Use of Online Account - [bug 1573802](https://bugs.launchpad.net/owncloud-sync/+bug/1573802), in the hope to get rid off the password in the config file in the future
1. Change the frequencies from seconds to hours,
1. Acknowledge qWebdavlib - [bug 1592750](https://bugs.launchpad.net/owncloud-sync/+bug/1592750)
1. New icon,

# Thanks

I would like to thank several projects / persons
1. [ownCloud-sync application](https://launchpad.net/owncloud-sync),
1. [Nextcloudcmd](https://docs.nextcloud.com/desktop/2.3/advancedusage.html), a Nextcloud client,
1. [qWebdavlib](https://github.com/mhaller/qwebdavlib) a Qt library for WebDAV,
1. Joan CiberSheep for the icon using [Suru Icon Theme elements](https://github.com/snwh/suru-icon-theme)


# Contribution

Any help on the code is welcome to enhance the app.


Ernesst
