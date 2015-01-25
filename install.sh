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

# check local env
#   fab, fab --version: Fabric 1.8.2, Paramiko 1.10.1
which fab > /dev/null 2>&1
if [ $? -ne 0 ] || [ ! -f `which fab` ]; then
    LOG ERROR "fab is required"
    exit 1
fi
# TODO: check ver
fab --version


# set hostname for hosts in conf/hosts
sub_proc ./bin/init_hostnames.sh


# check config
# after check config, all config is OK, so will not check getconfig.sh's return value
sub_proc ./bin/chk_config.sh


# check packages
sub_proc ./bin/chk_packages.sh 


# copy file to master machines, and run there

# init hosts
#   user,group
#   base dir
#   ssh no pwd
#   install jdk
#   hosts
sub_proc ./bin/init_hosts.sh


# check hosts
#   ntp, time
#   hostname
#   ping hostname
LOG INFO "TODO: check host if ready: ntp, network, ssh"


# check root passwd

# check config


# download packages
#   packages


# install env

# install zookeeper

# install hadoop

# install mysql (single point)

# install spark

# check install


exit 0

