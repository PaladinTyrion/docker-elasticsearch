docker run -d -it --net=host --privileged -p 9200:9200 -p 9300:9300 --name elasticsearch \
  -e ES_IPS=10.85.92.7,10.85.92.8,10.85.92.10,10.85.10.21,10.85.10.23,10.85.10.24,10.85.10.25 \
  -e ES_MASTER_IPS=10.85.92.7,10.85.92.8,10.85.92.10 \
  -e ES_DATANODE_IPS=10.85.92.7,10.85.92.8,10.85.10.21,10.85.10.23,10.85.10.24,10.85.10.25 \
  -e ES_HEAP_SIZE=10g \
  -v /data0/elk/elasticsearch/log:/var/log/elasticsearch \
  -v /data0/elk/elasticsearch/data:/var/lib/elasticsearch \
  -v /data0/elk/elasticsearch/tmp:/tmp/elasticsearch \
  registry.api.weibo.com/multi-media-structure/elasticsearch -d -m
