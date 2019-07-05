#!/bin/sh

if [[ -z "$INTERVAL_SEC" ]]; then
    seconds = 60
else
    seconds = $INTERVAL_SEC
fi

while true; do   
    sleep $seconds
    echo "executing task ..."
    sh /opt/bin/task.sh
done