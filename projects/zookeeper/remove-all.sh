#!/usr/bin/env bash

data_dir="/data/rt_cluster/zookeeper"
app_dir="/usr/local/rt_cluster/zookeeper-3.4.6"

run_user="hdfs"

function remove()
{
    host=$1
    ssh $host "su $run_user -c 'cd $app_dir; ./bin/zkServer.sh stop'"
    ssh $host "rm -rf $data_dir $app_dir*"
}

remove 10.130.23.25
remove 10.130.23.26
remove 10.130.23.138

