#!/bin/bash

exit 0


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/../common/log.sh


if [ $# -ne 1 ]; then
    echo "Usage: $0 hostname"
    exit 1
fi


host=$1

# if already is IP, return what it is
if [ `echo $host | grep -P '^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)$' | wc -l` -eq 1 ]; then
    echo $host
    exit 0
fi

#
# get from conf/hosts
#
ip=`awk '$2=="'$host'"{print $1}' $DIR/../conf/hosts`
if [ -n "$ip" ]; then
    echo $ip
    exit 0
fi

#
# get from sys resolve
#
ip=`ping -c 1 -W 3 $host | head -1 | grep -Po '((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)'`
if [ -n "$ip" ]; then
    echo $ip
    exit 0
fi


exit 1
