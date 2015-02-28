#!/usr/bin/env bash

. common/log.sh
. common/util.sh

#
# init this machine as master
#


# require fabric
#   apt-get install fabric

    # fab, fab --version: Fabric 1.8.2, Paramiko 1.10.1
    which fab > /dev/null 2>&1
    if [ $? -ne 0 ] || [ ! -f `which fab` ]; then
        LOG ERROR "fab is required"
        exit 1
    fi

    # TODO: check ver
    # fab --version 

    # TODO: not use fab


# set hostname of all machines
    sub_proc ./bin/init_hostnames.sh


# check config
    ##   after check config, all config is OK, so will not check getconfig.sh's return value
    #sub_proc ./bin/chk_config.sh
    #LOG INFO "SUCCEED: check config"




# common host init will do in init-slaves.sh


# 
LOG INFO "set_ssh_no_pwd_to_slaves"
./set_ssh_no_pwd_to_slaves.sh


