# MariaDB on Galera Cluster
A mariadb Docker image with Galera cluster capability and healtchecking script listening on 9200 for use with HAProxy. Based on [Olafz percona-clustercheck](https://github.com/olafz/percona-clustercheck) slightly modified to work in an automated fashion with this image.

Based on https://github.com/murf0/docker-mariadb-galera but modded for Dockercloud

# How to use
No initial seed of the mysql db is done. Copy in your existing inno-db instance into /var/lib/mysql of the first container then restart. It's done this way to ensure that no initialization writes over database that you want to save.

Set this Environment variable.
```
wsrep_sst_auth=<SST_REPLICATION_SQL_USER>:<PASSWORD_FOR_SQL_USER>
```

#HA Proxy
When using the Dockercloud settings the tutum.yaml stackfile can be used.
The extra environment variables for MariaDB containers setup the tcp-proxy settings. And a tiny netcat shell-script server serves status of the instance.
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
Only add new nodes when all current nodes are full masters in the 