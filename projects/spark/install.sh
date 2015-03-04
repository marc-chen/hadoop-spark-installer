#!/usr/bin/env bash

. ./../../common/log.sh
. ./../../bin/utils.sh


################################################################################
#
# read conf
#

# zookeeper.quorum
#   like m1.hadoop:2181,m2.hadoop:2181,m3.hadoop:2181
zk_hosts=$(../../bin/getconfig.sh zookeeper.hostnames)
zk_quorum=$(echo $zk_hosts | sed 's/,/:2181,/g')":2181"
print_var zk_quorum

data_dir="${CLUSTER_BASEDIR_DATA}/spark"
log_dir="${CLUSTER_BASEDIR_LOG}/spark"

masters=$(../../bin/getconfig.sh spark.master.hostnames | sed 's/,/ /g')
print_var masters
slaves=$( ../../bin/getconfig.sh spark.slave.hostnames  | sed 's/,/ /g')
print_var slaves
all_hosts=`for h in $masters $slaves; do echo $h; done | sort -u`
print_var all_hosts
echo


################################################################################
#
# make conf
#

rm -rf conf
mkdir conf


for m in $masters; do
    echo $m
done > conf/masters


for s in $slaves; do
    echo $s
done > conf/slaves


master_uri="spark://"$(echo "$masters" | sed 's/ /:7077,/g')":7077"
echo "
spark.master $master_uri
" > conf/spark-defaults.conf


echo "#!/usr/bin/env bash

export HADOOP_CONF_DIR=${CLUSTER_BASEDIR_INSTALL}/hadoop

export SPARK_DAEMON_JAVA_OPTS=\"-Dspark.deploy.recoveryMode=ZOOKEEPER -Dspark.deploy.zookeeper.url=$zk_quorum -Dspark.deploy.zookeeper.dir=/spark \"

export SPARK_LOG_DIR=$log_dir
" > conf/spark-env.sh


{
    echo "export SPARK_USER=${CLUSTER_USER}"
    echo "export SPARK_GROUP=${CLUSTER_GROUP}"
    echo "export SPARK_PREFIX=${CLUSTER_BASEDIR_INSTALL}/spark"
} >> admin_env.sh

. admin_env.sh


################################################################################
#
# copy package and conf, make dir
#

function install()
{
    host=$1

    ssh $SSH_OPTS $host "mkdir -p ${CLUSTER_BASEDIR_INSTALL}"

    # copy pkg and extract package
    scp ${CLUSTER_PACKAGE_DIR}/${CLUSTER_PROJECT_SPARK_PKG_NAME} $host:${CLUSTER_BASEDIR_INSTALL}
    echo "copy package end"

    ssh $host "
      cd ${CLUSTER_BASEDIR_INSTALL};
      tar xf ${CLUSTER_PROJECT_SPARK_PKG_NAME}
      rm -f spark
      ln -s ${CLUSTER_PROJECT_SPARK_NAME} spark
    "

    # conf
    scp -r conf/* $host:${CLUSTER_BASEDIR_INSTALL}/${CLUSTER_PROJECT_SPARK_NAME}/conf/

    ssh $host "
        for d in ${log_dir} ${CLUSTER_BASEDIR_INSTALL} ; do
            mkdir -p \$d
            chown -R $CLUSTER_USER  \$d
            chgrp -R $CLUSTER_GROUP \$d
        done
    "
}


for spark_host in $all_hosts; do
    echo "> install $spark_host"
    sleep 3
    ip=$(../../bin/nametoip.sh $spark_host)
    echo "ip: $ip"
    {
        install $ip
    } &
    wait
    echo "> install $spark_host end"
    echo
done


for host in $masters; do
    host=$(../../bin/nametoip.sh $host)
    scp $SSH_OPTS -v admin.sh admin_env.sh $host:${SPARK_PREFIX}
    ssh $SSH_OPTS $host "chown -R $CLUSTER_USER ${SPARK_PREFIX}; chgrp -R $CLUSTER_GROUP ${SPARK_PREFIX}"
done



