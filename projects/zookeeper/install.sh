#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 hostnames"
    exit 0
fi

install_hosts="$1"


data_dir="${CLUSTER_BASEDIR_DATA}/zookeeper"
log_dir="${CLUSTER_BASEDIR_LOG}/zookeeper"

# install_base_dir="${CLUSTER_BASEDIR_INSTALL}"

#zookeeper_name="zookeeper-3.4.6"
#zookeeper_name=${CLUSTER_PROJECT_ZK_NAME}

#pkg="$zookeeper_name.tar.gz"
#pkg=${CLUSTER_PROJECT_ZK_PKG_NAME}

#run_user="hdfs"




function install()
{
    host=$1
    myid=0
	if [ $# -eq 2 ]; then myid=$2; fi

    echo "installing [$myid] $host ..."

    # clean dir
    #ssh $host "
    #    rm -rf $data_dir;
    #    rm -rf ${CLUSTER_BASEDIR_INSTALL}/$zookeeper_name
    #"

    # copy pkg, conf

    scp ${CLUSTER_PROJECT_ZK_PKG_NAME} $host:${CLUSTER_BASEDIR_INSTALL}
    ssh $host "cd ${CLUSTER_BASEDIR_INSTALL};
    rm -rf tmp.zk; mkdir tmp.zk;
    mv ${CLUSTER_PROJECT_ZK_PKG_NAME} ./tmp.zk;
    tar xf ./tmp.zk/* ./tmp.zk
    tmpdir=\$(ls -lt ./tmp.zk | grep ^d | head -1 | awk '{print $NF}')

    # for existing dir, not delete, just overwrite packages
    if [ -d ${CLUSTER_PROJECT_ZK_NAME} ]; then
        cp -r ./tmp.zk/\$tmpdir/* ./${CLUSTER_PROJECT_ZK_NAME}/
    else
        mv ./tmp.zk/\$tmpdir ./${CLUSTER_PROJECT_ZK_NAME}
    fi
    # rm -rf ./tmp.zk
    mkdir -p ./${CLUSTER_PROJECT_ZK_NAME}/conf

    rm -f zookeeper
    ln -s ${CLUSTER_PROJECT_ZK_NAME} zookeeper
    "

    scp -r conf/* $host:${CLUSTER_BASEDIR_INSTALL}/${CLUSTER_PROJECT_ZK_NAME}/conf/

    # set owner, dir
    ssh $host "
        mkdir -p $data_dir
		if [ $myid -gt 0 ]; then
			echo $myid > $data_dir/myid
		fi

        mkdir -p $log_dir
        chown -R $CLUSTER_USER  $data_dir $log_dir ${CLUSTER_BASEDIR_INSTALL}
        chgrp -R $CLUSTER_GROUP $data_dir $log_dir ${CLUSTER_BASEDIR_INSTALL}
    "
}


id=1
for host in `echo $install_hosts | sed 's/,/\n/g'`; do
    echo "install $id $host ..."
    install $host $id
    id=$((id + 1))
done


