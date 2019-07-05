#!/bin/sh

if [[ -z "$INTERVAL" ]]; then
    interval=1m
else
    interval=$INTERVAL
fi

while true; do   
    sleep $interval
    echo "executing task..."
    sh /opt/bin/task.sh
done