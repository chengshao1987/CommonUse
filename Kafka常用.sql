
--kafka查看log文件
bin/kafka-run-class.sh kafka.tools.DumpLogSegments --files /tmp/kafka-logs/test3-0/00000000000000000000.log  --print-data-log
