#!/bin/bash

. common/log.sh

if [ $# -ne 2 ]; then
    echo "Usage:"
    echo "    $0 set env"
    echo "    $0 set pwd-less-ssh"
    echo "    $0 install zookeeper"
    echo "    $0 install hadoop"
    exit 0
fi

# TODO:
#   1. 安装机器，master 机器如何选？所有 master 机器都要配置 ssh 免密登录，要么手工，要么安装 fab 等工具
#       建议：安装的机器，用 master 机器, 所有 master 机器都安装 fab
#       毕竟要高可用，万一某台安装机器挂了，还有其它机器顶上 :)



case $1 in
    set)
        case $2 in
            env|pwd-less-ssh)
                ;;
            *)
                exit 1
        esac 
        ;;
    install)
        case $2 in
            zookeeper|hadoop)
                ;;
            *)
                exit 1
            ;;
        esac
        ;;
    *)
        exit 1
esac



function sub_proc()
{
    $*
    if [ $? -ne 0 ]; then
        # clean
        exit 1
    fi
}



# check local env:

if [ $1 == "set" ] && [ $2 == "env" ]; then

    # fab, fab --version: Fabric 1.8.2, Paramiko 1.10.1
    which fab > /dev/null 2>&1
    if [ $? -ne 0 ] || [ ! -f `which fab` ]; then
        LOG ERROR "fab is required"
        exit 1
    fi
    # TODO: check ver
    # fab --version 


    # set hostname for hosts in conf/hosts, should before chk_config
    sub_proc ./bin/init_hostnames.sh


    # check config
    #   after check config, all config is OK, so will not check getconfig.sh's return value
    sub_proc ./bin/chk_config.sh
    LOG INFO "SUCCEED: check config"



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
    sub_proc ./bin/chk_packages.sh 
    LOG INFO "SUCCEED: check packages"


    # 
    LOG INFO "set_ssh_no_pwd_to_slaves"
    ./set_ssh_no_pwd_to_slaves.sh



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
    sub_proc ./bin/init_hosts.sh
    LOG INFO "SUCCEED: init hosts"
    
    
    # check hosts
    #   ntp, time
    #   hostname
    #   ping hostname
    LOG INFO "TODO: check host if ready: ntp, network, ssh"
    
    
    # check root passwd
fi


# set env for scripts after
. ./bin/set_env.sh


if [ $1 == "set" ] && [ $2 == "pwd-less-ssh" ]; then
    echo "TODO"
fi


function install_proj()
{
    proj=$1
    echo
    LOG DEBUG "install $proj"
    echo
    cd ./projects/$proj
    ./install.sh
    # ./remove.sh
    cd -
}

# install zookeeper, hadoop
if [ $1 == "install" ]; then
    install_proj $2
fi



# install mysql (single point)

# install spark

# check install


exit 0

