#!/bin/bash

. common/log.sh

function usage()
{
    echo "Usage: $0 {zookeeper|hadoop}"
}

if [ $# -ne 1 ]; then
    usage
    exit 0
fi


case $1 in
    zookeeper|hadoop)
        ;;
    *)
        usage
        exit 1
esac



# set env for scripts after
. ./bin/set_env.sh



# TODO: check when installing the project
#    # check packages
#    sub_proc ./bin/chk_packages.sh 
#    LOG INFO "SUCCEED: check packages"




function install_proj()
{
    proj=$1
    echo
    LOG DEBUG "install $proj"
    echo
    cd ./projects/$proj

    # 生成默认 admin_env.sh
    {
        echo "export HADOOP_USER=${CLUSTER_USER}"
        echo "export HADOOP_GROUP=${CLUSTER_GROUP}"
        echo "export HADOOP_PREFIX=${CLUSTER_BASEDIR_INSTALL}/$proj"
    } > admin_env.sh

    ./install.sh
    # ./remove.sh
    cd -
}

# install zookeeper, hadoop
install_proj $1



# install mysql (single point)

# install spark

# check install

function get_all_master_hostname()
{
  {
    $DIR/getconfig.sh admin.hostnames;
    $DIR/getconfig.sh zookeeper.hostnames;
    $DIR/getconfig.sh hadoop.namenode.hostnames;
    $DIR/getconfig.sh spark.master.hostnames;
  } | sed 's/[,;]/\n/g' | sort -u | grep -v '^$'
}

for host in $(get_all_master_hostname); do
    scp $SSH_OPTS -v projects/admin.sh $host:${CLUSTER_BASEDIR_INSTALL}
done


exit 0

