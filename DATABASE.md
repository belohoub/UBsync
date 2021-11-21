# Database

UBSync uses the local sqlite database to share config between QML application and daemon.


# Accounts : SyncAccounts Table

This table holds account information

The following columns are included:
  * *accountID* - account identifier; type = INTEGER PRIMARY KEY
  * *accountName* - custom user account name - any string; type = TEXT
  * *remoteAddress* - remote server address; type = TEXT
  * TODO REMOVE *remoteUser* - remote server username; type = TEXT
  * *syncHidden* - sync hidden files setting; type = BOOLEAN
  * *useMobileData* - sync when mobile data setting; type = BOOLEAN
  * *syncFreq* - sync frequency; indexes of pre-defined values in hours ({0, 1, 2, 4, 6, 12, 24, 48, 168}); type = INTEGER
  * TODO ADD *serviceName* - type of remote service; currently "Owncloud" or "Nextcloud"; type = TEXT
  
# Targets : SyncTargets Table

This table holds terget information. Target is remote/local directory sync pair.

The following columns are included:
  * *targetID* - target identifier; type = INTEGER PRIMARY KEY
  * *accountID* - account identifier the target is connected to an account (!); type = INTEGER
  * *targetName* - custom user target name - any string; type = TEXT
  * *localPath* - local pyth; type = TEXT
  * *remotePath* - remote path; type = TEXT
  * *active* - is this target active (targets may be temporarily deactivated by setting *active* FALSE); type = BOOLEAN