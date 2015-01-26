#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


export CLUSTER_BASEDIR_INSTALL=$($DIR/getconfig.sh basedir.install)
export CLUSTER_BASEDIR_DATA=$($DIR/getconfig.sh basedir.data)
export CLUSTER_BASEDIR_LOG=$($DIR/getconfig.sh basedir.log)

export CLUSTER_USER=$($DIR/getconfig.sh run.user)
export CLUSTER_GROUP=$($DIR/getconfig.sh run.group)

export CLUSTER_PACKAGE_DIR="$DIR/../packages"

# like zookeeper-3.4.6.tar.gz
export CLUSTER_PROJECT_ZK_PKG_NAME=$($DIR/getconfig.sh package.zookeeper)
export CLUSTER_PROJECT_ZK_NAME=$(echo ${CLUSTER_PROJECT_ZK_PKG_NAME} | awk -F".tar.gz|.tgz" '{print $1}')


# TODO: print all evn

