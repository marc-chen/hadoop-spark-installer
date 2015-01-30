#!/bin/bash

. common/log.sh

function sub_proc()
{
    $*
    if [ $? -ne 0 ]; then
        # clean
        exit 1
    fi
}

# check local env:
#   fab, fab --version: Fabric 1.8.2, Paramiko 1.10.1
which fab > /dev/null 2>&1
if [ $? -ne 0 ] || [ ! -f `which fab` ]; then
    LOG ERROR "fab is required"
    exit 1
fi
fab --version # TODO: check ver


# set hostname for hosts in conf/hosts, should before chk_config
##sub_proc ./bin/init_hostnames.sh


# check config
#   after check config, all config is OK, so will not check getconfig.sh's return value
##sub_proc ./bin/chk_config.sh
##LOG INFO "SUCCEED: check config"



# TODO:
# set up password-less SSH login from this machine to all machines in the cluster
#
# set up password-less SSH login from every master machines to all slave machines
#     for hadoop: all namenodes to all datanodes
#     for spark : all masters to all slaves

# 理论上仅这一步依赖 fab 或其它不需要密码就可以执行远程操作的工具，比如 sshpass, expect
# 默认这3个工具在 ubuntu 14.04.1 LTS 和 Cent OS 6.4 上都没有安装
# so 选择哪个呢？虽然从安装上看 fab 不一定是最佳，但却是最好用的


# set env for scripts after
. ./bin/set_env.sh



# check packages
##sub_proc ./bin/chk_packages.sh 
LOG INFO "SUCCEED: check packages"



# copy file to master machines, and run there

# init hosts
#   user,group
#   base dir
#   ssh no pwd
#   install jdk
#   hosts
echo
echo "Init hosts"
echo
##sub_proc ./bin/init_hosts.sh
##LOG INFO "SUCCEED: init hosts"


# check hosts
#   ntp, time
#   hostname
#   ping hostname
LOG INFO "TODO: check host if ready: ntp, network, ssh"




# check root passwd



# install zookeeper
echo
LOG DEBUG "install zookeeper"
echo
cd ./projects/zookeeper
#./install.sh
./remove.sh
cd -

# install hadoop

# install mysql (single point)

# install spark

# check install


exit 0

