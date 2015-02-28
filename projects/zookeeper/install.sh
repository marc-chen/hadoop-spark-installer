#!/usr/bin/env bash


install_hosts=`../../bin/getconfig.sh zookeeper.hostnames`

data_dir="${CLUSTER_BASEDIR_DATA}/zookeeper"
log_dir="${CLUSTER_BASEDIR_LOG}/zookeeper"


################################################################################
#
# make conf
#
rm -rf conf; mkdir conf
cp conf.template/zoo.cfg ./conf

data_dir_escape=$(echo "$data_dir" | sed 's/\//\\\//g')
#echo $data_dir_escape
sed -i 's/^dataDir=.*/dataDir='"$data_dir_escape"'/' ./conf/zoo.cfg

sed -i '/^server\.\d/d' conf/zoo.cfg 
id=1
for host in $(echo $install_hosts | sed 's/,/\n/g'); do
    echo "server.$id=$host:2371:3371" >> ./conf/zoo.cfg
    id=$((id + 1))
done


# admin_env.sh
{
    echo "export ZOOKEEPER_USER=${CLUSTER_USER}"
    echo "export ZOOKEEPER_GROUP=${CLUSTER_GROUP}"
    echo "export ZOOKEEPER_PREFIX=${CLUSTER_BASEDIR_INSTALL}/zookeeper"
} >> admin_env.sh



################################################################################
#
# install
#

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

    ssh $SSH_OPTS $host "mkdir -p ${CLUSTER_BASEDIR_INSTALL}"

    # copy pkg, conf

    scp ${CLUSTER_PACKAGE_DIR}/${CLUSTER_PROJECT_ZK_PKG_NAME} $host:${CLUSTER_BASEDIR_INSTALL}

    ssh $host "cd ${CLUSTER_BASEDIR_INSTALL};

    rm -rf tmp.zk; mkdir tmp.zk;
    mv ${CLUSTER_PROJECT_ZK_PKG_NAME} ./tmp.zk/;

    tar xf ./tmp.zk/* -C ./tmp.zk/
    tmpdir=\$(ls -lt ./tmp.zk | grep ^d | head -1 | awk '{print \$NF}')
    echo tmpdir: \$tmpdir

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

    scp -r admin.sh admin_env.sh $host:${CLUSTER_BASEDIR_INSTALL}/${CLUSTER_PROJECT_ZK_NAME}/

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
for host in $(echo $install_hosts | sed 's/,/\n/g'); do
    ip=$(../../bin/nametoip.sh $host)
    echo "install $id $host($ip) ..."
    install $ip $id
    id=$((id + 1))
done


# rm -rf conf
