#!/usr/bin/env bash

if [ `whoami` == "root" ]; then
    echo "root is not allowed"
    exit 1
fi

. admin_env.sh


if [ $# -ne 1 ]; then
    echo "Usage: $0 {stop|start|restart}"
    exit 1
fi


function start()
{
    ./sbin/start-all.sh

    sleep 5

    # start other masters
    for m in $(cat conf/masters | grep -v `hostname`); do
        ssh $m "cd $SPARK_PREFIX; ./sbin/start-master.sh"
    done

    # try again for some unforeseen circumstances
    sleep 5
    ./sbin/start-slaves.sh
}


function stop()
{
    ./sbin/stop-all.sh

    # force stop all Masters
    for m in `cat conf/masters`; do
        ssh $m "cd $SPARK_PREFIX; ./sbin/stop-master.sh;"
        sleep 1
        ssh $m 'jps | awk '"'"'$2=="Master"{print $1}'"'"' | xargs kill -9'
    done

    # force stop all Works
    for host in `cat conf/slaves`; do
        ssh $host 'jps | awk '"'"'$2=="Worker"{print $1}'"'"' | xargs kill -9'
    done
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
    clean)
        for host in `cat conf/masters conf/slaves | awk '{print $1}' | sort -u`; do
            echo "clean $host old logs ..."
            ssh $host "find $SPARK_PREFIX/work -maxdepth 1 -type d -mtime +30 | xargs rm -rf"
        done
        ;;
    *)
        exit 1
        ;;
esac

