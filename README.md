# MariaDB on Galera Cluster
A mariadb Docker image with Galera cluster capability and healthchecking script listening on 9200 for use with HAProxy.
Based on [Olafz percona-clustercheck](https://github.com/olafz/percona-clustercheck) slightly modified to work in 
an automated fashion with this image.

Based on https://github.com/murf0/docker-mariadb-galera but modded for Dockercloud

# How to use
No initial seed of the mysql db is done. Copy in your existing inno-db instance into /var/lib/mysql of the 
first container then restart. It's done this way to ensure that no initialization writes over database 
that you want to save.

Set this Environment variable.
```
wsrep_sst_auth=<SST_REPLICATION_SQL_USER>:<PASSWORD_FOR_SQL_USER>
```

#HA Proxy
When using the Dockercloud settings the dockercompose.yml stackfile can be used.
The extra environment variables for MariaDB containers setup the tcp-proxy settings. 
And a tiny netcat shell-script server serves status of the instance.
Additional environment variables needed in the mariadb container: 

```
BALANCE=leastconn
EXCLUDE_PORTS=4567,4568,4444,9200
HEALTH_CHECK=check port 9200 inter 5000 fastinter 2000 rise 2 fall 2
OPTION=httpchk
TCP_PORTS=3306
```
These are pulled into the haproxy container from the mariadb container.

#Know limitations
In a galera cluster when a node joins a full master drops out to do the initial sync with this new node. This takes some time during this time no new nodes that need a full sync can join the cluster.

##Mitigation
Only add new nodes when all current nodes are full masters

#Backup
The `:s3backup` version of this container can be run as part of a cluster of non-backup MariaDBGalera 
containers and will perform backups to s3 dependant on the configured cron schedule

### Automatic Periodic Backups

You can set the `SCHEDULE` environment variable like `-e SCHEDULE="@daily"` to run the backup automatically.
More information about the scheduling can be found 
[here](http://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).


### Restoring from backup

This container also contains a script to restore a backup from s3. The container should not be part of a cluster when 
perfomring a restore. To run a restore an additional environment needs to be set `RESTORE_FILENAME` which contains 
the name of the file to copy from s3 and restore from. In order to restore run the container and execute
the command:

    /usr/local/bin/s3restore.sh
   
This will restore the database to the _/var/lib/mysql_ directory
