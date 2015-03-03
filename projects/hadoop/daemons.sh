#!/usr/bin/env bash

. assert_user.sh


if [ $# -ne 2 ]; then
    echo "Usage: $0 <hdfs|yarn> {start|stop|ha-status}"
    exit 1
fi

if [ -f admin_env.sh ]; then
    . admin_env.sh
fi


c_type=$1
act=$2

# 
# read config from dir conf/
#
cfg_namenodes=$(./bin/hdfs getconf -namenodes | grep -v WARN)
cfg_namenode_a=`echo $cfg_namenodes | awk '{print $1}'`

cfg_nn_has=$(./bin/hdfs getconf -confKey dfs.ha.namenodes.hacluster | grep -v WARN | sed 's/,/ /')



if [ $c_type == "hdfs" ]; then
    case $act in
        "start")
            action=./sbin/start-dfs.sh
            ssh ${cfg_namenode_a} "cd $HADOOP_PREFIX; $action"
            ;;
        "stop")
            action=./sbin/stop-dfs.sh
            ssh ${cfg_namenode_a} "cd $HADOOP_PREFIX; $action"
            ;;
        "ha-status")
            for nn in ${cfg_nn_has}; do
                echo -n "namenode: $nn "
                echo -n "health: "
                echo -n $(cd $HADOOP_PREFIX; ./bin/hdfs haadmin -checkHealth $nn; echo $?)
                echo -n " status: "
                echo $(cd $HADOOP_PREFIX; ./bin/hdfs haadmin -getServiceState $nn)
            done
            ;;
        *)
            exit 1
            ;;
    esac
fi



if [ $c_type == "yarn" ]; then
    case $act in
        "start")
            action=./sbin/start-yarn.sh
            for nn in ${cfg_namenodes}; do
                ssh $nn "cd $HADOOP_PREFIX; $action"
            done
            ;;
        "stop")
            action=./sbin/stop-yarn.sh
            for nn in ${cfg_namenodes}; do
                ssh $nn "cd $HADOOP_PREFIX; $action"
            done
            ;;
        "ha-status")
            for n in `seq 1 2`; do
                # 注意保持格式不变，监控脚本会用到
                echo -n "resource manager: $n "
                echo -n "health: "
                echo -n $(cd $HADOOP_PREFIX; ./bin/yarn rmadmin -checkHealth rm$n; echo $?)
                echo -n " status: "
                echo $(cd $HADOOP_PREFIX; ./bin/yarn rmadmin -getServiceState rm$n)
            done
            ;;
        *)
            exit 1
            ;;
    esac
fi


