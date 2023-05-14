# UBsync

UBsync is the featured application for [OwnCloud](https://owncloud.com/)/[Nextcloud](https://nextcloud.com/) synchronization on [Ubuntu Touch](https://ubports.com/).

[![OpenStore](https://open-store.io/badges/en_US.png)](https://open-store.io/app/ubsync)

<img src="https://framagit.org/ernesst/UBsync/raw/master/Owncloud-Sync/UBsync.png" width="196">

## Common UBsync Recommendations
* Do not synchronize the entire home folder, because it can be quite big and certain fast-evolving files (caches, or profiles) may induce many file versions in the cloud. Rather set up several targets and select individual folders.
* UBsync can be used to back up your app configs to Owncloud/Nextcloud
* Application sync support tips:
  * UBsync can be used to sync [Activity Tracker](https://open-store.io/app/activitytracker.cwayne18) app and Nextcloud GPXedit
  * UBsync can be used to sync [Crazy Mark](https://open-store.io/app/crazy-mark.timsueberkrueb) app with Nextcloud Notes
  * UBsync can be used to sync your music files
  * ...

## Upgrade/Post-Install Recommendations
* Reboot your phone after installation - backend daemon  is started by upstart and will be properly initialized when you log out and log in, the simpler way is probably to reboot your phone

## App Permissions
UBsync requests explicitly following permissions:
1. Online Accounts - to be able to use Owncloud/Nextcloud accounts already set up in system settings
1. Networking - as a cloud synchronization app, it naturally needs network access

Additionally, UBsync is an *unconfined* app, which means, that it is not limited by any AppArmor security policies.
This application needs to be *unconfined*, as the pre-defined AppArmor policies do not permit all of UBsyncs' vital features:
1. gain read/write access to any folder you wish to synchronize
1. create the backend daemon (*Owncloudsyncd*) by upstart for background synchronisation
1. *UBsync-ui* to *Owncloudsyncd* communication through *DBUS*

As unconfined apps may introduce security risks, you can review the app's source code or even build the app by yourself to be sure, that the app is not harmful.

Please note, that *unconfined* applications in [OpenStore](https://open-store.io/) are manually [reviewed](https://open-store.io/about).

To get the source code, go to [GitHub](https://github.com/belohoub/UBsync) to download and review the UBsync source code.

To build the app, install [Clickable](https://clickable-ut.dev/en/latest/) (v7.0.0 or above), open a terminal, clone the UBsync repo, change into the UBsync folder and run `clickable`.

## Project History
UBsync was originally forked from [ownCloud-sync](https://launchpad.net/owncloud-sync), a dedicated Nextcloud application for **Ubuntu touch**,  supported by [UBports](https://www.ubports.com).

This repository continues, where [UBsync Launchpad Project](https://code.launchpad.net/~ocs-team/owncloud-sync/UBsync) finished.

This fork was originally created as a reaction to the discussion at [forums.ubports.com](https://forums.ubports.com/topic/5116/help-creating-an-ubsync-arm64-version/30) related to missing arm64 support for UBsync.

Later the development was returned to Launchpad for a short period. After discussions in the developers/testers community (12/2021 - since version 0.7),
the development was moved to GitHub, as GitHub remains one of two major platforms,
where UBports community lives and Github-centric development is more comfortable for current maintainers.

Code evolution is briefly documented in the [changelog](CHANGELOG.md).

## Credits

We would like to thank several projects/persons:
1. [ownCloud-sync application](https://launchpad.net/owncloud-sync),
1. [Nextcloudcmd](https://docs.nextcloud.com/desktop/2.3/advancedusage.html), a Nextcloud client,
1. [qWebdavlib](https://github.com/mhaller/qwebdavlib) a Qt library for WebDAV,
1. Joan CiberSheep for the icon using [Suru Icon Theme elements](https://github.com/snwh/suru-icon-theme)

### Current and Past Contributors
  * [Jan Belohoubek](https://github.com/belohoub/)
  * [Ernesst](https://github.com/ernesst/)
  * [ownCloud-sync](https://launchpad.net/owncloud-sync)
    * [Dubstar_04](https://launchpad.net/~dubstar-04)
    * [Filip Dorosz](https://launchpad.net/~fihufil)
    * [Nekhelesh Ramananthan](https://launchpad.net/~nik90)
    * Jan Belohoubek
    * Ernesst aka "slash"

## Contribute

Please use the [issue tracker](https://github.com/belohoub/UBsync/issues) to report a bug or request a new feature.
Any help on the code is welcomed to enhance the app!


### Translations

For translation instructions please read this page from the [docs](https://docs.ubports.com/en/latest/contribute/translations.html).

This app currently uses the [Weblate](https://hosted.weblate.org/projects/ubports/ubsync/) translation service. 

Alternativelly, you can create or edit the *.po* file for your language and commit this new/changed *.po* file as a pull request.


### Documentation
  * [BUILD.md](BUILD.md)
  * [DATABASE.md](DATABASE.md)
