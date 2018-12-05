#!/bin/sh
function waitPort() {
    while ! nc -vz $1 $2; do   
        sleep 2
    done
}

if [[ -z "$ZOOKEEPER_CONNECT" ]]; then
    echo "ERROR: missing mandatory config: ZOOKEEPER_CONNECT"
    exit 1
else
    zk_host=`echo $ZOOKEEPER_CONNECT | cut -d \: -f 1`
    zk_port=`echo $ZOOKEEPER_CONNECT | cut -d \: -f 2`

    waitPort $zk_host $zk_port
fi

sed -r -i "s/(coordinator_addr)=(.*)/\1=\"$ZOOKEEPER_CONNECT\"/g" /config/dashboard.toml
sed -r -i "s/(product_name)=(.*)/\1=\"$PRODUCT_NAME\"/g" /config/dashboard.toml
sed -r -i "s/(product_auth)=(.*)/\1=\"$PRODUCT_AUTH\"/g" /config/dashboard.toml
sed -r -i "s/(sentinel_quorum)=(.*)/\1=$SENTINEL_QUORUM/g" /config/dashboard.toml
sed -r -i "s/(sentinel_down_after)=(.*)/\1=\"$SENTINEL_DOWN_AFTER\"/g" /config/dashboard.toml

# launch dashboard
nohup codis-dashboard --config=/config/dashboard.toml \
    --log=/log/dashboard.log \
    --host-admin=127.0.0.1:18080 &
    
# wait until dashboard launched
waitPort 127.0.0.1 18080

proxy_num=$PROXY_NUM

for i in $(seq 0 $(( proxy_num-1 ))); do
    suffix=$(( i+1 ))
    adminPort=$(( 11080+i ))
    proxyPort=$(( 19000+i ))

    cp /config/proxy_sample.toml /config/proxy_$suffix.toml
    sed -r -i "s/(product_name)=(.*)/\1=\"$PRODUCT_NAME\"/g" /config/proxy_$suffix.toml
    sed -r -i "s/(product_auth)=(.*)/\1=\"$PRODUCT_AUTH\"/g" /config/proxy_$suffix.toml
    sed -r -i "s/(session_auth)=(.*)/\1=\"$SESSION_AUTH\"/g" /config/proxy_$suffix.toml
    sed -r -i "s/(admin_addr)=(.*)/\1=\"0.0.0.0:$adminPort\"/g" /config/proxy_$suffix.toml
    sed -r -i "s/(proxy_addr)=(.*)/\1=\"0.0.0.0:$proxyPort\"/g" /config/proxy_$suffix.toml
    sed -r -i "s/(jodis_addr)=(.*)/\1=\"$ZOOKEEPER_CONNECT\"/g" /config/proxy_$suffix.toml

    # launch proxy
    nohup codis-proxy --ncpu=2 --config=/config/proxy_$suffix.toml \
      --log=/log/proxy_$suffix.log \
      --host-admin 127.0.0.1:$adminPort \
      --host-proxy 127.0.0.1:$proxyPort &
    # wait until proxy launched
    waitPort 127.0.0.1 $adminPort

    # add proxy to dashboard
    codis-admin --dashboard=127.0.0.1:18080 --create-proxy --addr=127.0.0.1:$adminPort
done

group_num=$GROUP_NUM
slave_num=$SLAVE_NUM_PER_GROUP

member_num=$(( slave_num+1 ))

index=0
for group in $(seq 1 $group_num); do
    # create group
    codis-admin --dashboard=127.0.0.1:18080 --create-group --gid=$group

    for i in $(seq 1 $member_num); do
        port=$(( 6380 + index ))

        cp /config/redis_sample.conf /config/redis_$port.conf

        sed -r -i "s/(port) (.*)/\1 $port/g" /config/redis_$port.conf
        sed -r -i "s/(logfile) (.*)/\1 \"\/log\/redis_$port.log\"/g" /config/redis_$port.conf
        sed -r -i "s/(pidfile) (.*)/\1 \"\/var\/run\/redis_$port.pid\"/g" /config/redis_$port.conf
        sed -r -i "s/(dbfilename) (.*)/\1 \"dump_$port.rdb\"/g" /config/redis_$port.conf
        sed -r -i "s/(requirepass) (.*)/\1 $PRODUCT_AUTH/g" /config/redis_$port.conf
        sed -r -i "s/(masterauth) (.*)/\1 $PRODUCT_AUTH/g" /config/redis_$port.conf

        # launch redis server
        nohup codis-server /config/redis_$port.conf &
        waitPort 127.0.0.1 $port
    
        # add redis server to group
        codis-admin --dashboard=127.0.0.1:18080 --group-add --gid=$group --addr=127.0.0.1:$port
    
        # do synchronization when it is slave
        if [ $(( index%member_num )) -ne 0 ]; then
            codis-admin --dashboard=127.0.0.1:18080 --sync-action --create --addr=127.0.0.1:$port
        fi
        
        let index+=1
    done
done

if [ ! -z "$ADD_EXTRA_REDIS" -a "$ADD_EXTRA_REDIS" == 'true' ]; then
    for port in $(seq 6377 6378); do

        cp /config/redis_sample.conf /config/redis_$port.conf

        sed -r -i "s/(port) (.*)/\1 $port/g" /config/redis_$port.conf
        sed -r -i "s/(logfile) (.*)/\1 \"\/log\/redis_$port.log\"/g" /config/redis_$port.conf
        sed -r -i "s/(pidfile) (.*)/\1 \"\/var\/run\/redis_$port.pid\"/g" /config/redis_$port.conf
        sed -r -i "s/(dbfilename) (.*)/\1 \"dump_$port.rdb\"/g" /config/redis_$port.conf
        sed -r -i "s/(requirepass) (.*)/\1 $PRODUCT_AUTH/g" /config/redis_$port.conf
        sed -r -i "s/(masterauth) (.*)/\1 $PRODUCT_AUTH/g" /config/redis_$port.conf

        # launch redis server
        nohup codis-server /config/redis_$port.conf &
        waitPort 127.0.0.1 $port
    done
fi

for port in $(seq 26379 26381)
do
    cp /config/sentinel_sample.conf /config/sentinel_$port.conf

    sed -r -i "s/(port) (.*)/\1 $port/g" /config/sentinel_$port.conf
    sed -r -i "s/(logfile) (.*)/\1 \"\/log\/sentinel_$port.log\"/g" /config/sentinel_$port.conf
    sed -r -i "s/(pidfile) (.*)/\1 \"\/var\/run\/sentinel_$port.pid\"/g" /config/sentinel_$port.conf

    # launch redis sentinel
    nohup redis-sentinel /config/sentinel_$port.conf &
    waitPort 127.0.0.1 $port

    codis-admin --dashboard=127.0.0.1:18080 --sentinel-add --addr=127.0.0.1:$port
done

# sync all sentinels
codis-admin --dashboard=127.0.0.1:18080 --sentinel-resync

if [ ! -z "$AUTO_ASSIGN_SLOTS" -a "$AUTO_ASSIGN_SLOTS" == 'true' ]; then
    # auto rebalance all slots
    codis-admin --dashboard=127.0.0.1:18080 --rebalance --confirm
fi

sed -r -i "s/(\"name\":) (.*)/\1 \"$PRODUCT_NAME\",/g" /config/codis.json

# launch fe
codis-fe --dashboard-list=/config/codis.json \
    --log=/log/fe.log \
    --listen=0.0.0.0:18090