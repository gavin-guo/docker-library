#!/bin/bash

java -cp /kafkaOffsetMonitor.jar com.quantifind.kafka.offsetapp.OffsetGetterWeb \
--offsetStorage kafka \
--kafkaBrokers localhost:9092 \
--zk localhost:2181 \
--port ${KAFKA_MONITOR_PORT} \
--refresh 10.seconds \
--retain 2.days