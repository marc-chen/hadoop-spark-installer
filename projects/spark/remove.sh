#!/usr/bin/env bash

. ./../../common/log.sh
. ./../../bin/utils.sh

. ../../bin/set_env.sh

install_dir="${CLUSTER_BASEDIR_INSTALL}/spark"
log_dir="${CLUSTER_BASEDIR_LOG}/spark"


# stop master
for host in $(../../bin/getconfig.sh spark.master.hostnames | sed 's/,/ /g'); do
    echo "> stop master $host"
    sleep 1
    ssh $host "su $CLUSTER_USER -c 'cd $install_dir; ./admin.sh stop'"
    echo
done

# rm file
{
    ../../bin/getconfig.sh spark.master.hostnames
    ../../bin/getconfig.sh spark.slave.hostnames
} | sed 's/[,;]/\n/g' | sort -u | while read host;
do
    echo "> clean $host dir"
    sleep 1
    ssh $host "rm -rf ${CLUSTER_BASEDIR_INSTALL}/${CLUSTER_PROJECT_SPARK_NAME} $install_dir $log_dir" &
    wait
    echo
done


