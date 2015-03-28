#!/usr/bin/env bash

# 配置从机器A到机器B的免密码 ssh 登录
# 前提：本机到 A、B 已经配置了免密码登录

if [ $# -ne 3 ]; then
    echo "Usage: $0 SRC_IP DST_IP user"
    exit 1
fi

host_src=$1
host_dst=$2
user="$3"


# get home dir of both hosts, and test root pwd-less ssh by the way

home_src=`ssh ${host_src} "su hdfs -c 'cd && pwd'"`
if [ $? -ne 0 ] || [ -z "$home_src" ]; then
    echo "ERROR: get home dir of $user at ${host_src} failed"
    exit 1
fi
home_dst=`ssh ${host_dst} "su hdfs -c 'cd && pwd'"`
if [ $? -ne 0 ] || [ -z "$home_dst" ]; then
    echo "ERROR: get home dir of $user at ${host_dst} failed"
    exit 1
fi

#echo $home_src
#echo $home_dst


# 
type='rsa'


# source : gen public key
ssh ${host_src} "
    if [ ! -f ${home_src}/.ssh/id_$type.pub ]; then
        sudo -u $user ssh-keygen -t $type -P '' -f ${home_src}/.ssh/id_$type
    fi
"


# copy to local
scp ${host_src}:${home_src}/.ssh/id_$type.pub ./ > /dev/null 2>&1

# direct copy fail
#   scp ${host_src}:${home_src}/.ssh/id_$type.pub ${host_dst}:${home_dst}/


#
# B
#

# init dst dir .ssh
ssh ${host_dst} "su $user -c 'if [ ! -d ~/.ssh ]; then mkdir ~/.ssh; fi; touch ~/.ssh/authorized_keys'"

# cp to B
scp ./id_$type.pub ${host_dst}:${home_dst}/ > /dev/null 2>&1
rm ./id_$type.pub

# merge to authorized_keys, and uniq file
ssh ${host_dst} "cd ${home_dst}; cat id_$type.pub >> .ssh/authorized_keys; rm id_$type.pub; sort .ssh/authorized_keys | uniq > t.\$\$; cat t.\$\$ > .ssh/authorized_keys; rm t.\$\$"


# test
ssh -o StrictHostKeyChecking=no ${host_src} "su hdfs -c 'ssh -o StrictHostKeyChecking=no ${host_dst} pwd'" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "set pwd-less ssh from $host_src to $host_dst SUCCEED"
else
    echo "set pwd-less ssh from $host_src to $host_dst FAIL"
fi



