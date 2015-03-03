#!/bin/bash

. assert_user.sh


if [ $# -ne 1 ]; then
    echo "Usage $0 <start|stop>"
    exit 1
fi

if [ -f admin_env.sh ]; then
    . admin_env.sh
fi


function daemon()
{
    host=$1
    cmd=$2
    # ssh $host "su $HADOOP_USER -c 'cd $HADOOP_PREFIX; ./sbin/hadoop-daemon.sh $cmd journalnode'"
    ssh $host "cd $HADOOP_PREFIX; ./sbin/hadoop-daemon.sh $cmd journalnode"
}

for host in `cat conf/journalnodes`; do
    echo "$host :"
    daemon $host $1
done

