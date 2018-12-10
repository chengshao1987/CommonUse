
--kafka查看log文件
bin/kafka-run-class.sh kafka.tools.DumpLogSegments --files /tmp/kafka-logs/test3-0/00000000000000000000.log  --print-data-log

--启动zookeeper
bin/zookeeper-server-start.sh config/zookeeper.properties 

--启动server
bin/kafka-server-start.sh config/server.properties 

--查看某个topic的日志
bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic world

