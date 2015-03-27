#!/usr/bin/env bash

#
# 配置中大部分使用 hostname 来引用主机，但当前安装机器可能没有配置正确的 /etc/hosts 或 dns
# 故提供一个工具，从 hostname 转 ip, 方便安装过程中各脚本使用
#

# exit 0


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/../common/log.sh


#if [ $# -lt 1 ]; then
#    echo "Usage: $0 hostname"
#    exit 1
#fi


# must exist in conf/hosts
function toip()
{
    host=$1
    
    # if already is IP, return what it is
    #if [ `echo $host | grep -P '^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)$' | wc -l` -eq 1 ]; then

        # is IP
        if [ `awk '$1=="'$host'"{print $0}' $DIR/../conf/hosts | wc -l` -gt 0 ]; then
            echo $host
            return
        fi
    #fi
    
    # is name
    ip=`awk '$2=="'$host'"{print $1}' $DIR/../conf/hosts`
    if [ -n "$ip" ]; then
        echo $ip
        return
    fi
    
    echo "unknown_host_$host"
}

if [ $# -gt 0 ]; then
    toip $1
    exit 0
else
    while read host; do
        toip $host
    done
fi



exit 0



#
# get from sys resolve
#
ip=`ping -c 1 -W 3 $host | head -1 | grep -Po '((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)'`
if [ -n "$ip" ]; then
    echo $ip
    exit 0
fi


exit 1
