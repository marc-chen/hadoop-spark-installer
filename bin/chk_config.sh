#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/../common/log.sh

cfg_value=""
function cfg_require()
{
    k=$1
    v=`$DIR/getconfig.sh $k`
    cfg_value="$v"
    LOG DEBUG "get $k = $v"
    if [ -z "$v" ]; then
        LOG ERROR "config $k is required"
        exit 1
    fi
}

declare -a cfg_value_arr
function cfg_require_hostname_lists()
{
    unset cfg_value_arr
    echo "check config $k ..."
    k=$1
    v=`$DIR/getconfig.sh $k`
    LOG DEBUG "get $k = $v"
    if [ -z "$v" ]; then
        LOG ERROR "config $k is required"
        exit 1
    fi
    i=0
    # echo $v | sed 's/[,;]/\n/g' | while read host; do
    for host in `echo $v | sed 's/[,;]/\n/g'`; do
        ip=`$DIR/nametoip.sh $host | grep -v '^unknown_host'`
        if [ -z "$ip" ]; then
            LOG ERROR "unknown host $host, maybe not defined in conf/hosts"
            exit 1
        fi
        ping -c 1 -W 3 $ip > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            LOG ERROR "$host unreachable"
            exit 1
        fi
        cfg_value_arr[$i]=$host
        i=$((i+1))
    done
}



# TODO: ntp server

v=`$DIR/getconfig.sh ntp.server`
if [ -z "$v" ]; then
    LOG WARN "config ntp.server is empty, time sync is strongly suggested"
    sleep 3
    # exit 1
else
    LOG DEBUG "TODO: check ntp server"
  if [ 0 -gt 1 ]; then
    /usr/sbin/ntpdate -t 3 $v > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        LOG ERROR "ntp.server $v error"
        sleep 3
        # exit 1
    else
        LOG INFO "check config ntp.server SUCCEED"
    fi
  fi
fi



# ssh port, pwd

cfg_require ssh_port
cfg_require root_passwd_def



# packages

os_bit=`getconf LONG_BIT`
if [ "$os_bit" == "64" ]; then
    echo "check OS 64 bit"
else
    echo "require 64 bit OS"
    exit 1
fi

function chk_pkg_file()
{
    url="$1"
    if [ ! -f ${CLUSTER_PACKAGE_DIR}/$cfg_value ]; then
        LOG ERROR "package not found!"
        LOG INFO  "download page: $url"
        LOG INFO  "mirrors.cnnic.cn is best for China Telecom users"
        exit 1
    fi
}

cfg_require package.jdk
chk_pkg_file "http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html"
if [ `echo "$cfg_value" | grep 64 | wc -l` -eq 0 ]; then
    LOG ERROR "require x64 version of JDK"
    exit 1
fi


cfg_require package.zookeeper
chk_pkg_file "http://www.apache.org/dyn/closer.cgi/zookeeper/"
cfg_require package.hadoop
chk_pkg_file "http://www.apache.org/dyn/closer.cgi/hadoop/common/"
cfg_require package.spark
chk_pkg_file "http://spark.apache.org/downloads.html"


# public dir

cfg_require basedir.install
cfg_require basedir.log
cfg_require basedir.data



# run user, group

cfg_require run.user
cfg_require run.group



# zookeeper

cfg_require_hostname_lists zookeeper.hostnames
n=${#cfg_value_arr[*]}
echo ${cfg_value_arr[*]}
echo $n
if [ $((n%2)) -ne 1 ]; then
    LOG ERROR "zookeeper host' count must be an odd number: 2n+1"
    exit 1
fi



# hadoop

cfg_require_hostname_lists hadoop.namenode.hostnames
n=${#cfg_value_arr[*]}
if [ $n -ne 2 ]; then
    LOG ERROR "require exactly 2 hadoop namenode"
    exit 1
fi

cfg_require_hostname_lists hadoop.journalnode.hostnames
n=${#cfg_value_arr[*]}
if [ $((n%2)) -ne 1 ]; then
    LOG ERROR "hadoop journalnode's count must be an odd number: 2n+1"
    exit 1
fi

cfg_require_hostname_lists hadoop.datanode.hostnames
n=${#cfg_value_arr[*]}
if [ $n -lt 2 ]; then
    LOG ERROR "require at least 2 hadoop datanode"
    exit 1
fi

cfg_require hadoop.datanode.databasedirs


# spark

cfg_require_hostname_lists spark.master.hostnames
if [ ${#cfg_value_arr[*]} -lt 2 ]; then
    LOG ERROR "require at least 2 spark masters"
    exit 1
fi

cfg_require_hostname_lists spark.slave.hostnames
if [ ${#cfg_value_arr[*]} -lt 2 ]; then
    LOG ERROR "require at least 2 spark slaves"
    exit 1
fi



