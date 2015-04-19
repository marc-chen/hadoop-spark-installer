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


sub_proc ./bin/chk_config.sh;
LOG INFO "check config SUCCEED"
sleep 1



################################################################################
# pwd-less
#

function set_root_pwdless() {
	# set ssh root pwd-less to all
	for ip in $(getallhostip); do
	    sub_proc set_ssh_pwd_less_login $ip root
	    LOG INFO "set pwdless login $ip SUCCEED";
	done
	echo
}


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
    set_root_pwdless;

    # set hostname of all machines
    sub_proc ./bin/init_hostnames.sh
    LOG INFO "set hostname for all hosts SUCCEED";
    echo

    # copy to other master
    work_dir="/tmp/spark-installer"
    rm -f ${work_dir}.tar.gz
    tar --exclude packages --exclude .git --exclude install.sh -zcvf ${work_dir}.tar.gz .

    # for host in $(get_all_master_hostname); do
    for host in $(get_all_master_ip); do
        ssh $SSH_OPTS $host "rm -rf ${work_dir}; mkdir ${work_dir}"
        scp $SSH_OPTS -v ${work_dir}.tar.gz $host:${work_dir}
        ssh $SSH_OPTS $host "cd ${work_dir}; tar xvf *.tar.gz"
        LOG INFO "copy install package to $host SUCCEED";
        echo
    done
    echo

    # init user/group/datadir/...
    echo "> init all host base env"
    sub_proc ./init-all.sh
    LOG INFO "init all SUCCEED";


    # init master
    # TODO: 降低要求，master 机器不需要安装 fab，仅当前机器
    #   方法：init-master 的工作由当前机器进行，步骤拆分一下，先 ken-gen，然后拉回本地，再追加到目标机器
    sub_proc ./init-master.sh
    LOG INFO "init master SUCCEED";


    # install projects
    # 重复了，去掉
    #install_proj zookeeper
    #install_proj hadoop
    #install_proj spark
}



################################################################################

case $1 in
    zookeeper|hadoop|spark)
        sub_proc install_proj $1
		LOG INFO "install $1 SUCCEED";
        ;;
    pwd-less )
	sub_proc set_root_pwdless;
	LOG INFO "set root pwdless SUCCEED";
	exit 0;
	;;
    all)
        sub_proc install_env;
		LOG INFO "install env SUCCEED";
        sub_proc install_proj zookeeper
		LOG INFO "install zookeeper SUCCEED";
        sub_proc install_proj hadoop
		LOG INFO "install hadoop SUCCEED";
        sub_proc install_proj spark
		LOG INFO "install spark SUCCEED";
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
    LOG INFO "scp admin.sh to all hosts SUCCEED";

#fi

#sub_proc ./remove.sh root-pwd-less

LOG INFO "Conguatulations! all install SUCCEED";
exit 0

