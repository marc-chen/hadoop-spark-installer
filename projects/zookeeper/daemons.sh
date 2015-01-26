#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 {start|start-foreground|stop|restart|status|upgrade|print-cmd}"
    exit 1
fi

action=$1

for n in ns1 ns2 ns3; do
    host=$n.spark.bi

    ssh $host "su hdfs -c 'cd /usr/local/rt_cluster/zookeeper-3.4.6; ./bin/zkServer.sh $action'"
done

