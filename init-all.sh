#!/usr/bin/env bash

. common/log.sh
. common/utils.sh


##function get_all_hostname()
##{
##    {
##    $DIR/getconfig.sh zookeeper.hostnames;
##    $DIR/getconfig.sh hadoop.namenode.hostnames;
##    $DIR/getconfig.sh hadoop.datanode.hostnames;
##    $DIR/getconfig.sh spark.master.hostnames;
##    $DIR/getconfig.sh spark.slave.hostnames
##    $DIR/getconfig.sh client.hostnames; 
##    } | sed 's/[,;]/\n/g' | sort -u | grep -v '^$'
##}
#
##for host in $(get_all_hostname); do

# init all slave machines, run after init-master


    # copy file to master machines, and run there
    
    # init hosts
    #   user,group
    #   base dir
    #   ssh no pwd
    #   install jdk
    #   hosts
    #echo
    #echo "Init hosts"
    #echo

# 其实不只是 slave, 而是所有节点，因为操作是相同的

grep -P '^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)' ./conf/hosts \
| awk 'NF==2{print $0}' | sort -u \
| while read ip host; do

    sub_proc ./bin/init_host.sh $ip $host

done    
if [ $? -ne 0 ]; then
    LOG ERROR "init host failed";
    exit 1;
fi;
    
    # check hosts
    #   ntp, time
    #   hostname
    #   ping hostname
    LOG INFO "TODO: check host if ready: ntp, network, ssh"
    
    
    # check root passwd

