#!/bin/bash

# install ifconfig nfs-client
yum install -y net-tools nfs-utils rpcbind
service rpcbind restart
service nfs restart
service nfslock restart

# create dir
mkdir -p /data0/elk/elasticsearch
mkdir -p /data0/elk/kibana
chmod -R +x /data0/elk

### create groups && users
# create elasticsearch user
id "elasticsearch" >& /dev/null
if [ $? -ne 0 ]
then
    groupadd -r elasticsearch -g 441
    useradd -r -s /usr/sbin/nologin -M -c "Elasticsearch service user" -u 441 -g elasticsearch elasticsearch
fi
# create kibana user
id "kibana" >& /dev/null
if [ $? -ne 0 ]
then
    groupadd -r kibana -g 443
    useradd -r -s /usr/sbin/nologin -c "Kibana service user" -u 443 -g kibana kibana
fi
# chown groups && users
chown -R elasticsearch:elasticsearch /data0/elk/elasticsearch
chown -R kibana:kibana /data0/elk/kibana

# get local_ip
local_ip=`/sbin/ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:" | head -n 1`

# elk mount dir
echo "10.10.10.1:/data2/${local_ip}.elk/elasticsearch /data0/elk/elasticsearch nfs auto,soft,bg,intr,rw,rsize=262144,wsize=262144 0 0" >> /etc/fstab
echo "10.10.10.1:/data2/${local_ip}.elk/kibana /data0/elk/kibana nfs auto,soft,bg,intr,rw,rsize=262144,wsize=262144 0 0" >> /etc/fstab

# mount
mount -a
