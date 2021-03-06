#!/bin/sh
T=$(curl -s -H "Authorization: $DOCKERCLOUD_AUTH" $DOCKERCLOUD_SERVICE_API_URL | jq '.' | grep ENV_DOCKERCLOUD_IP_ADDRESS | grep -v ${DOCKERCLOUD_IP_ADDRESS} | awk -F\" '{print $4}' | awk -F\/ '{print $1}' | sort -u)
CLUSTER=""
for Y in $T; do
    CLUSTER="${CLUSTER}${Y},"
    #Wait for a 200 from each of your buddies.
    #while [ ! "$(curl -s -o /dev/null -w "%{http_code}" ${Y}:9200)" = "200" ];do
    #    echo "${Y} is not ready Waiting 5"
    #    sleep 5
    #done
done
#Make sure mysql owns /var/lib/mysql
chown -R mysql:mysql /var/lib/mysql

CLUSTER="${CLUSTER%?}"
NODE_ADDR=$(echo ${DOCKERCLOUD_IP_ADDRESS} | awk -F\/ '{print $1}')

VOLUME_HOME="/var/lib/mysql"

if [ "x${CLUSTER}" = "x" ]; then
    echo "I'm alone ${NODE_ADDR} Bootstrap Cluster (Throw away container if this is not the first container)"
    CLUSTER="gcomm://"
else
    echo "I'm not alone! My buddies: ${CLUSTER} and me ${NODE_ADDR}"
    CLUSTER="gcomm://${CLUSTER}"
fi
echo /usr/bin/mysqld_safe --wsrep_sst_auth=wsrep_sst_auth --wsrep_node_address="${NODE_ADDR}" --wsrep_node_incoming_address="${NODE_ADDR}" --wsrep_cluster_address="${CLUSTER}" --wsrep_node_name=${HOSTNAME} ${EXTRA_OPTIONS}
/usr/bin/mysqld_safe --wsrep_sst_auth=${wsrep_sst_auth} --wsrep_node_address="${NODE_ADDR}" --wsrep_node_incoming_address="${NODE_ADDR}" --wsrep_cluster_address="${CLUSTER}" --wsrep_node_name=${HOSTNAME} ${EXTRA_OPTIONS}