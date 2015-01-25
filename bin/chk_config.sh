#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/../common/log.sh

function cfg_require()
{
    k=$1
    v=`$DIR/getconfig.sh $k`
    LOG DEBUG "get $k = $v"
    if [ -z "$v" ]; then
        LOG ERROR "config $k is required"
        exit 1
    fi
}

function cfg_require_hostname_lists()
{
    k=$1
    v=`$DIR/getconfig.sh $k`
    LOG DEBUG "get $k = $v"
    if [ -z "$v" ]; then
        LOG ERROR "config $k is required"
        exit 1
    fi
    echo $v | sed 's/[,;]/\n/g' | while read host; do
        ping -c 1 -W 3 $host > /dev/null 2>&1
        # TODO: hostname 可能还没配置好，此时检查注定失败
    done
}

v=`$DIR/getconfig.sh ntp.server`
if [ -z "$v" ]; then
    LOG ERROR "config ntp.server is empty, time sync is strongly suggested"
    exit 1
else
    /usr/sbin/ntpdate -t 3 $v > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        LOG ERROR "ntp.server $v error"
        # TODO
        # exit 1
    else
        LOG INFO "check config ntp.server SUCCEED"
    fi
fi


cfg_require package.jdk
cfg_require package.zookeeper
cfg_require package.hadoop
cfg_require package.spark

# TODO: set default 

cfg_require install.basedir
cfg_require log.basedir

cfg_require run.user
cfg_require_hostname_lists admin.hostnames

cfg_require_hostname_lists zookeeper.hostnames

cfg_require_hostname_lists hadoop.namenode.hostnames
cfg_require_hostname_lists hadoop.datanode.hostnames
cfg_require hadoop.datanode.databasedirs

cfg_require_hostname_lists spark.master.hostnames
cfg_require_hostname_lists spark.slave.hostnames

# cfg_require client.hostnames


