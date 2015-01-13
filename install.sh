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
#   fab
which fab > /dev/null 2>&1
if [ $? -ne 0 ] || [ ! -f `which fab` ]; then
    LOG ERROR "fab is required"
    exit 1
fi


# check config
# after check config, all config is OK, so will not check getconfig.sh's return value
sub_proc ./bin/chk_config.sh

# check packages
sub_proc ./bin/chk_packages.sh 


# copy file to master machines, and run there

# init hosts
#   set hostname
#   user,group
#   base dir
#   ssh no pwd
#   install jdk
#   hosts

# check hosts
#   ntp, time
#   hostname
#   ping hostname

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

