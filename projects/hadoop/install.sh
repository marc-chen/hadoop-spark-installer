#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 hostnames"
    exit 0
fi

install_hosts="$1"

data_dir="${CLUSTER_BASEDIR_DATA}/zookeeper"
log_dir="${CLUSTER_BASEDIR_LOG}/zookeeper"


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../../common/log.sh

. $DIR/../../bin/utils.sh


fab_options=""

    pwd=$(get_pwd $host)
    port=$($DIR/getconfig.sh ssh_port)
    fab_options="--fabfile=$DIR/../env/fabfile.py --hosts=$ip:$port --password=$pwd"



# TODO: set qjournal machine, 


#
# make conf
#
rm -rf conf; mkdir conf
cp conf.ha.template/* ./conf/

# hdfs-site.xml

# ns1.spark.bi:2181,ns2.spark.bi:2181,ns3.spark.bi:2181
# TODO
sed -i 's/VALUE_ha.zookeeper.quorum_VALUE/'

# VAR_NAMENODE_1_VAR
# VAR_NAMENODE_2_VAR
# dfs.namenode.shared.edits.dir
# dfs.ha.fencing.ssh.private-key-files
# dfs.ha.fencing.methods
# dfs.journalnode.edits.dir
# dfs.namenode.name.dir
# dfs.datanode.data.dir


# conf/hadoop-env.sh
# conf/slaves
# conf/yarn-env.sh

# yarn-site.xml
#   TODO: update 



# sed -i '/^server\.\d/d' conf/zoo.cfg 

# set ssh no pwd, from namenode to datanode


#

function install()
{
    host=$1

    ssh $host "mkdir -p ${CLUSTER_BASEDIR_INSTALL}"

    # copy pkg and un package
    scp ${CLUSTER_PACKAGE_DIR}/${CLUSTER_PROJECT_HADOOP_PKG_NAME} $host:${CLUSTER_BASEDIR_INSTALL}
    ssh $host "
      cd ${CLUSTER_BASEDIR_INSTALL};
      tar xf ${CLUSTER_PROJECT_HADOOP_PKG_NAME}
    "

    # conf
    scp -r conf/* $host:${CLUSTER_BASEDIR_INSTALL}/${CLUSTER_PROJECT_HADOOP_NAME}/conf/

    ssh $host "
        for d in ... ; do
            mkdir -p \$d
            chown -R $CLUSTER_USER  \$d
            chgrp -R $CLUSTER_GROUP \$d
        done
    "
}

{
  ../../bin/getconfig.sh hadoop.namenode.hostnames
  ../../bin/getconfig.sh hadoop.datanode.hostnames
} | sed 's/[,;]/\n/g' | sort -u | grep -v '^$' \
| while read host; do
    ip=$(../../bin/nametoip.sh $host)
    echo "install  $host($ip) ..."
    install $ip
done



#rm -rf conf
