#!/bin/bash

. common/log.sh
. common/utils.sh
. bin/utils.sh

function usage()
{
    echo "Usage: $0 {all|zookeeper|hadoop|spark|pwd-less}"
}

if [ $# -ne 1 ]; then
    usage
    exit 0
fi


################################################################################
# local env
#


#
# check python, fab
#

# fab, fab --version: Fabric 1.8.2, Paramiko 1.10.1
which fab > /dev/null 2>&1
if [ $? -ne 0 ] || [ ! -f `which fab` ]; then
    LOG ERROR "fab is required"
    exit 1
fi
#which apt-get > /dev/null 2>&1
#if [ $? -eq 0 ]; then
#    apt-get -y install fabric
#fi



# set base env for scripts following
. ./bin/set_env.sh

# dir for packages
mkdir -p ${CLUSTER_PACKAGE_DIR}


./bin/chk_config.sh
if [ $? -ne 0 ]; then
    exit 1
fi
LOG INFO "check config SUCCEED"
sleep 1



################################################################################
# pwd-less
#


# set ssh root pwd-less to all
for ip in $(getallhostip); do
    set_ssh_pwd_less_login $ip root
done
echo


if [ "$1" == "pwd-less" ]; then
    exit 0
fi



################################################################################
# install
#


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
        echo "export SSH_OPTS='${SSH_OPTS}'"
        echo "export CLUSTER_USER=${CLUSTER_USER}"
        echo "export CLUSTER_GROUP=${CLUSTER_GROUP}"
        echo
    } > admin_env.sh

    ./install.sh
    cd -
}


function install_env()
{
    # set hostname of all machines
    ./bin/init_hostnames.sh
    echo

    # copy to other master
    work_dir="/tmp/spark-installer"
    rm -f ${work_dir}.tar.gz
    tar --exclude packages --exclude .git --exclude install.sh -zcvf ${work_dir}.tar.gz .

    for host in $(get_all_master_ip); do
        ssh $SSH_OPTS $host "rm -rf ${work_dir}; mkdir ${work_dir}"
        scp $SSH_OPTS -v ${work_dir}.tar.gz $host:${work_dir}
        ssh $SSH_OPTS $host "cd ${work_dir}; tar xvf *.tar.gz"
        echo
    done
    echo


    # init master
    # TODO: 降低要求，master 机器不需要安装 fab，仅当前机器
    #   方法：init-master 的工作由当前机器进行，步骤拆分一下，先 ken-gen，然后拉回本地，再追加到目标机器
    ./init-master.sh

    echo "> init all host base env"
    ./init-all.sh


    # install projects
    install_proj zookeeper
    install_proj hadoop
    install_proj spark
}



################################################################################

case $1 in
    all)
        install_env
        install_proj zookeeper
        install_proj hadoop
        install_proj spark
        ;;
    zookeeper|hadoop|spark)
        install_proj $1
        ;;
    *)
        usage
        exit 1
esac


# TODO:
#   install mysql (single point)
#   check if installing is succeed


#if [ "$1" == "all" ]; then
    # copy admin.sh to install-base-dir
    for host in $(get_all_master_ip); do
        scp $SSH_OPTS -v projects/admin.sh $host:${CLUSTER_BASEDIR_INSTALL}
    done

#fi

./remove.sh root-pwd-less
exit 0

