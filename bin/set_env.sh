#!/usr/bin/env bash
#
# 初始化一些环境变量，方便其它安装脚本使用
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


export CLUSTER_BASEDIR_INSTALL=$($DIR/getconfig.sh basedir.install)
export CLUSTER_BASEDIR_DATA=$($DIR/getconfig.sh basedir.data)
export CLUSTER_BASEDIR_LOG=$($DIR/getconfig.sh basedir.log)

export CLUSTER_USER=$($DIR/getconfig.sh run.user)
export CLUSTER_GROUP=$($DIR/getconfig.sh run.group)

export CLUSTER_PACKAGE_DIR="$DIR/../packages"


# like zookeeper-3.4.6.tar.gz
export CLUSTER_PROJECT_ZK_PKG_NAME=$($DIR/getconfig.sh package.zookeeper)
# zookeeper-3.4.6
export CLUSTER_PROJECT_ZK_NAME=$(echo ${CLUSTER_PROJECT_ZK_PKG_NAME} | awk -F".tar.gz|.tgz" '{print $1}')


# hadoop-2.6.0.tar.gz
export CLUSTER_PROJECT_HADOOP_PKG_NAME=$($DIR/getconfig.sh package.hadoop)
# hadoop-2.6.0
export CLUSTER_PROJECT_HADOOP_NAME=$(echo ${CLUSTER_PROJECT_HADOOP_PKG_NAME} | awk -F".tar.gz|.tgz" '{print $1}')


# spark-1.2.1-bin-hadoop2.4.tgz
export CLUSTER_PROJECT_SPARK_PKG_NAME=$($DIR/getconfig.sh package.spark)
# spark-1.2.1-bin-hadoop2.4
export CLUSTER_PROJECT_SPARK_NAME=$(echo ${CLUSTER_PROJECT_SPARK_PKG_NAME} | awk -F".tar.gz|.tgz" '{print $1}')


if [ "$SSH_OPTS" = "" ]; then
    SSH_OPTS="-o StrictHostKeyChecking=no"
fi

# TODO: print all evn

