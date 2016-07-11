# FreeNAS-Gogs
Gogs (gogs.io) install an update script for FreeNAS (and any FreeBSD Jail)

1. ```git clone https://github.com/jedediahfrey/FreeNAS-Gogs.git```
2. ```cd FreeNAS-Gogs```
3. ```./gogs_root.sh```

During initial setup, select "SQLite3" database type.

Final gogs folder is /usr/home/git/gogs/

/usr/home/git/.ssh is symlinked to /usr/home/git/gogs/.ssh to allow ssh access. 
