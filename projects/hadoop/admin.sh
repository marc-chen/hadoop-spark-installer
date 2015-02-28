#!/usr/bin/env bash

#if [ `whoami` == "root" ]; then
#    echo "please don't run as root"
#    exit 1
#fi

if [ ! -f admin_env.sh ]; then
    echo "ERROR: require file admin_env.sh"
    exit 1
fi

. admin_env.sh

if [ "$HADOOP_USER" == "" ] || [ `grep "^$HADOOP_USER:" /etc/passwd | wc -l` -eq 0 ] \
    || [ "$HADOOP_PREFIX" == "" ] || [ ! -d "$HADOOP_PREFIX" ]; then
    echo "check env failed"
    exit 1
fi


if [ $# -ne 1 ]; then
    echo "Usage: $0 {stop|start|restart}"
    exit 1
fi


function start()
{
    ./journalnode.sh start
    ./daemons.sh hdfs start
}

function stop()
{
    ./daemons.sh hdfs stop
    ./journalnode.sh stop
}


case $1 in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start
        ;;
    *)
        exit 1
        ;;
esac

