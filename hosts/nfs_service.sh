#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: ./nfs_service.sh [ips,[ip1,ip2,ip3,...]]"
fi

if [ -z "$1" ]; then
    echo "没有输入nfs-client ips"
    exit
fi

# install ifconfig nfs-client
yum install -y net-tools nfs-utils rpcbind
service rpcbind restart
service nfs restart


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

# get local_ip
local_ip=`/sbin/ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:" | head -n 1`

ips="$1"
### get all client_ips
oldIFS="$IFS"
# 自定义分隔符
IFS=","
for client_ip in $ips;
do
    mkdir -p /data2/${client_ip}.elk
    mkdir -p /data2/${client_ip}.elk/elasticsearch
    mkdir -p /data2/${client_ip}.elk/kibana
    chmod -R +x /data2/${client_ip}.elk
    # chown groups && users
    chown -R elasticsearch:elasticsearch /data2/${client_ip}.elk/elasticsearch
    chown -R kibana:kibana /data2/${client_ip}.elk/kibana
done
IFS="$oldIFS"
### use client_ips ends

# exportfs
oldIFS="$IFS"
# 自定义分隔符
IFS=","
for client_ip in $ips;
do
    echo "/data2/${client_ip}.elk/elasticsearch ${client_ip}(rw,sync,all_squash,anonuid=441,anongid=441,no_subtree_check)" >> /etc/exports
    echo "/data2/${client_ip}.elk/kibana ${client_ip}(rw,sync,all_squash,anonuid=443,anongid=443,no_subtree_check)" >> /etc/exports
done
IFS="$oldIFS"

# 生效nfs-service
exportfs -arv
