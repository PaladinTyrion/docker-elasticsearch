#!/bin/bash
# author: paladintyrion

#### start

es_conf_file="/etc/elasticsearch/elasticsearch.yml"
# echo "需要替换的es_conf_file为:" $es_conf_file
master_flag=false
data_flag=false

if [ ! -z "$ES_IPS" ]; then
  es_ips="$ES_IPS"
fi

if [ ! -z "$ES_MASTER_IPS" ]; then
  es_master_ips="$ES_MASTER_IPS"
fi

if [ ! -z "$ES_DATANODE_IPS" ]; then
  es_datanode_ips="$ES_DATANODE_IPS"
fi

if [ -z "$es_master_ips" ]; then
  es_master_ips="$es_ips"
fi

if [ -z "$es_datanode_ips" ]; then
  es_datanode_ips="$es_ips"
fi

for i in "$@"
do
case $i in
  -m|--master)
    master_flag=true
    ;;
  -d|--datanode)
    data_flag=true
    ;;
  *)
    ;;
esac
done

##### replace starts
oldIFS="$IFS"
IFS=","

# deal with es_ip
es_tcp_arr=()
for es_ip in $es_ips;
do
  es_tcp_arr=("${es_tcp_arr[@]}" "\"${es_ip}:9300\"")
done
es_tcp_ips_res="[${es_tcp_arr[*]// /,}]"
es_cluster_expect="${#es_tcp_arr[@]}"
es_cluster_min="$[${#es_tcp_arr[@]}/2+1]"

# deal with es_master_ip
es_master_arr=()
for es_master in $es_master_ips;
do
  es_master_arr=("${es_master_arr[@]}" "${es_master}")
done
es_master_expect="${#es_master_arr[@]}"
es_master_min="$[${#es_master_arr[@]}/2+1]"

# deal with es_datanode_ip
es_datanode_arr=()
for es_datanode in $es_datanode_ips;
do
  es_datanode_arr=("${es_datanode_arr[@]}" "${es_datanode}")
done
es_datanode_expect="${#es_datanode_arr[@]}"
es_datanode_min="$[${#es_datanode_arr[@]}/2+1]"

IFS="$oldIFS"
##### replace ends


##### modify the all configure

if [ ${#es_tcp_arr[@]} -gt 0 ]; then
  # replace elasticsearch configure *.yml unicast.hosts
  sed -i -e "s/^discovery.zen.ping.unicast.hosts:.*$/discovery.zen.ping.unicast.hosts: $es_tcp_ips_res/g" $es_conf_file
  sed -i -e "s/^discovery.zen.minimum_master_nodes:.*$/discovery.zen.minimum_master_nodes: $es_master_min/g" $es_conf_file
  # replace elasticsearch configure *.yml min runs
  sed -i -e "s/^gateway.recover_after_nodes:.*$/gateway.recover_after_nodes: $es_cluster_min/g" $es_conf_file
  sed -i -e "s/^gateway.recover_after_master_nodes:.*$/gateway.recover_after_master_nodes: $es_master_min/g" $es_conf_file
  sed -i -e "s/^gateway.recover_after_data_nodes:.*$/gateway.recover_after_data_nodes: $es_datanode_min/g" $es_conf_file
  # replace elasticsearch configure *.yml expected nodes
  sed -i -e "s/^gateway.expected_nodes:.*$/gateway.expected_nodes: $es_cluster_expect/g" $es_conf_file
  sed -i -e "s/^gateway.expected_master_nodes:.*$/gateway.expected_master_nodes: $es_master_expect/g" $es_conf_file
  sed -i -e "s/^gateway.expected_data_nodes:.*$/gateway.expected_data_nodes: $es_datanode_expect/g" $es_conf_file
fi

sed -i -e "s/^node.master:.*$/node.master: $master_flag/g" $es_conf_file
sed -i -e "s/^node.data:.*$/node.data: $data_flag/g" $es_conf_file
sed -i -e "s/^node.ingest:.*$/node.ingest: $data_flag/g" $es_conf_file
