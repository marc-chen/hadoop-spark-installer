#!/usr/bin/env bash

if [ `whoami` == "root" ]; then
    echo "root is not allowed"
    exit 1
fi


## only allowed run on namenode machind
#if [ $(grep "`hostname`:" conf/zoo.cfg | wc -l) -ne 1 ]; then
#    echo "this machine is not zookeeper node"
#    exit 1
#fi


# check env
if [ ! -f admin_env.sh ]; then
    echo "ERROR: require file admin_env.sh"
    exit 1
fi
. admin_env.sh
if [ "$ZOOKEEPER_USER" == "" ] || [ `grep "^$ZOOKEEPER_USER:" /etc/passwd | wc -l` -eq 0 ] \
    || [ "$ZOOKEEPER_PREFIX" == "" ] || [ ! -d "$ZOOKEEPER_PREFIX" ]; then
    echo "check env failed"
    exit 1
fi



if [ $# -ne 1 ]; then
    echo "Usage: $0 {start|start-foreground|stop|restart|status|upgrade|print-cmd}"
    exit 1
fi


action=$1

for host in $(grep '^server\.' conf/zoo.cfg | cut -d'=' -f2 | cut -d':' -f1 | sort -u); do
    ssh $SSH_OPTS $host "cd $ZOOKEEPER_PREFIX; ./bin/zkServer.sh $action"
done



