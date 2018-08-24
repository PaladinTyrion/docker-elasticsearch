docker run -d -it --net=host --privileged -p 9200:9200 -p 9300:9300 --name elasticsearch \
  -e ES_IPS=10.10.10.1,10.10.10.2,10.10.10.3,10.10.10.4,10.10.10.5 \
  -e ES_MASTER_IPS=10.10.10.5,10.10.10.6,10.10.10.7 \
  -e ES_DATANODE_IPS=10.10.10.1,10.10.10.2,10.10.10.3,10.10.10.4,10.10.10.5,10.10.10.6,10.10.10.7 \
  -e ES_HEAP_SIZE=10g \
  -v /data0/elk/elasticsearch/log:/var/log/elasticsearch \
  -v /data0/elk/elasticsearch/data:/var/lib/elasticsearch \
  -v /data0/elk/elasticsearch/tmp:/tmp/elasticsearch \
  registry.api.weibo.com/multi-media-structure/elasticsearch -d -m
