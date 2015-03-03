#!/usr/bin/env bash

. assert_user.sh


# only allowed run on namenode machind
if [ $(grep "^`hostname`$" conf/namenodes | wc -l) -ne 1 ]; then
    echo "this machine is not namenode"
    exit 1
fi


# check env
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
    ./daemons.sh hdfs start
    sleep 3
    ./daemons.sh yarn start
}

function stop()
{
    ./daemons.sh yarn stop
    sleep 3
    ./daemons.sh hdfs stop
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
        sleep 1
        start
        ;;
    *)
        exit 1
        ;;
esac

