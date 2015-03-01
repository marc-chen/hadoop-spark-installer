#!/usr/bin/env bash

. common/log.sh
. common/utils.sh
. ./bin/utils.sh

#
# init this machine as master
#


# require fabric
#   apt-get install fabric


which apt-get > /dev/null 2>&1
if [ $? -eq 0 ]; then
    apt-get -y install fabric
fi


    # fab, fab --version: Fabric 1.8.2, Paramiko 1.10.1
    which fab > /dev/null 2>&1
    if [ $? -ne 0 ] || [ ! -f `which fab` ]; then
        LOG ERROR "fab is required"
        exit 1
    fi


    # TODO: not use fab



# check config
    ##   after check config, all config is OK, so will not check getconfig.sh's return value
    #sub_proc ./bin/chk_config.sh
    #LOG INFO "SUCCEED: check config"




# common host init will do in init-slaves.sh


# 
LOG INFO "set master ssh password-less to all slave machines"
{
    ./bin/getconfig.sh hadoop.datanode.hostnames
    ./bin/getconfig.sh spark.slave.hostnames
} \
| sed 's/[,;]/\n/g' | sort -u | grep -v '^$' \
| while read host; do

    ip=$(./bin/nametoip.sh $host)
    user=$(./bin/getconfig.sh run.user)
    group=$(./bin/getconfig.sh run.group)

    set_ssh_pwd_less_login $ip $user $group

done


