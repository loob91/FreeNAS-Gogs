# FreeNAS-Gogs
Gogs (gogs.io) install an update script for FreeNAS (and any FreeBSD Jail)

0. ```cd /tmp```
0. ```fetch --no-verify-peer https://github.com/jedediahfrey/FreeNAS-Gogs/archive/master.zip```
0. ```unzip master.zip```
0. ```cd /FreeNAS-Gogs-master```
0. ```./gogs_root.sh```

During initial setup, select "SQLite3" database type.

Final gogs folder is /usr/home/git/gogs/

/usr/home/git/.ssh is symlinked to /usr/home/git/gogs/.ssh to allow ssh access. 
