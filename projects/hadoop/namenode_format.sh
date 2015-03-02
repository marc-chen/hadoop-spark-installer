#!/usr/bin/env bash

echo
echo "###########################################################"
echo "## WARNING: only run once just after hadoop be installed ##"
echo "###########################################################"
echo
read -p "Press any key to continue ... "


################################################################################
#
# init hadoop
#

# start journalnode
echo "> start journal node"
read -p "Press any key to continue ... "
./journalnode.sh start
echo

# format namenode
echo "> format name node"
read -p "Press any key to continue ... "
./bin/hdfs namenode -format
echo

# format zookeeper
echo "> format zookeeper"
read -p "Press any key to continue ... "
./bin/hdfs zkfc -formatZK
echo

# 
echo "> stop journal node"
read -p "Press any key to continue ... "
./journalnode.sh stop
echo


echo "> format namenode over, you can start hadoop by run ./admin.sh"

