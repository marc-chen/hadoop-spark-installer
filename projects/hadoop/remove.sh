#!/usr/bin/env bash

. ./../../common/log.sh
. ./../../bin/utils.sh

. ../../bin/set_env.sh

install_dir="${CLUSTER_BASEDIR_INSTALL}/hadoop"
data_dir="${CLUSTER_BASEDIR_DATA}/hadoop"
log_dir_hdfs="${CLUSTER_BASEDIR_LOG}/hdfs"
log_dir_yarn="${CLUSTER_BASEDIR_LOG}/yarn"
databasedirs=$(../../bin/getconfig.sh hadoop.datanode.databasedirs | sed 's/[,;]/ /g')


# hadoop master
masters=$(../../bin/getconfig.sh hadoop.namenode.hostnames)
m1=$(echo $masters | cut -d',' -f1 | ../../bin/nametoip.sh)
m2=$(echo $masters | cut -d',' -f2 | ../../bin/nametoip.sh)


for host in $m1 $m2; do
    echo "> stop master $host"
    sleep 1
    ssh $host "su $CLUSTER_USER -c 'cd $install_dir; ./admin.sh stop'"
    echo
done

for host in $m1 $m2; do
    echo "> clean master $host"
    sleep 1
    ssh $host "rm -rf ${CLUSTER_BASEDIR_INSTALL}/${CLUSTER_PROJECT_HADOOP_NAME} $install_dir $data_dir $log_dir_hdfs $log_dir_yarn"
    echo
done

slaves=$(../../bin/getconfig.sh hadoop.datanode.hostnames | sed 's/[,;]/\n/g' | ../../bin/nametoip.sh)
for host in $slaves; do
    echo "> clean datanode $host data dir: $databasedirs"
    sleep 1
    ssh $host "rm -rf $databasedirs" &
    wait
    echo
done


