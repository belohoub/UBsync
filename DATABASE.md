# Database

UBSync uses the local sqlite database to share config between QML application and daemon.


# Accounts : SyncAccounts Table

This table holds account information

The following columns are included:
  * *accountID* - account identifier; type = INTEGER PRIMARY KEY
  * *accountName* - custom user account name - any string; type = TEXT
  * *remoteAddress* - remote server address; type = TEXT
  * *remoteUser* - remote server username; (currently unused); type = TEXT
  * *syncHidden* - sync hidden files setting; type = BOOLEAN
  * *useMobileData* - sync when mobile data setting; type = BOOLEAN
  * *syncFreq* - sync frequency; indexes of pre-defined values in hours ({0, 1, 2, 4, 6, 12, 24, 48, 168}); type = INTEGER
  * *serviceName* - type of remote service; (currently unused) "" or "owncloud" or "nextcloud"; type = TEXT

# Targets : SyncTargets Table

This table holds target information. Target means a remote/local directory sync pair.

The following columns are included:
  * *targetID* - target identifier; type = INTEGER PRIMARY KEY
  * *accountID* - account identifier the target is connected to an account (!); type = INTEGER
  * *targetName* - custom user target name - any string; type = TEXT
  * *localPath* - local pyth; type = TEXT
  * *remotePath* - remote path; type = TEXT
  * *active* - is this target active (targets may be temporarily deactivated by setting *active* FALSE); type = BOOLEAN
  * *lastSync* - last synchronization time; type = TEXT
