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

# default admin_env.sh
{
    echo "# env shared by all projects"
    echo "export SSH_OPTS=${SSH_OPTS}"
    echo "export CLUSTER_USER=${CLUSTER_USER}"
    echo "export CLUSTER_GROUP=${CLUSTER_GROUP}"
    echo
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


# copy admin.sh to install-base-dir

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

