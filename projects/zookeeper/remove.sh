#!/usr/bin/env bash


install_hosts=`../../bin/getconfig.sh zookeeper.hostnames`

data_dir="${CLUSTER_BASEDIR_DATA}/zookeeper"
log_dir="${CLUSTER_BASEDIR_LOG}/zookeeper"

run_user="hdfs"

function remove()
{
    host=$1
    ssh $host "su $run_user -c 'if [ -d zookeeper ]; then cd zookeeper; ./bin/zkServer.sh stop; fi'"
    ssh $host "rm -rf $data_dir $log_dir ${CLUSTER_BASEDIR_INSTALL}/zookeeper ${CLUSTER_BASEDIR_INSTALL}/${CLUSTER_PROJECT_ZK_NAME}"
}

for host in $(echo $install_hosts | sed 's/,/\n/g'); do
    echo "remove zookeeper from $host"
    ip=$(../../bin/nametoip.sh $host)
    remove $ip
done

