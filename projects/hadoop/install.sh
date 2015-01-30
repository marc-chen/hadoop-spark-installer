#!/usr/bin/env bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/../../common/log.sh
. $DIR/../../bin/utils.sh



#
# read conf
#

data_dir="${CLUSTER_BASEDIR_DATA}/hadoop"

# zookeeper.quorum
#   like m1.hadoop:2181,m2.hadoop:2181,m3.hadoop:2181
zk_hosts=$(../../bin/getconfig.sh zookeeper.hostnames)
zk_quorum=$(echo $zk_hosts | sed 's/,/:2181,/g')":2181"
print_var zk_quorum

# hadoop master
masters=$(../../bin/getconfig.sh hadoop.namenode.hostnames)
m1=$(echo $masters | cut -d',' -f1)
m2=$(echo $masters | cut -d',' -f2)
print_var masters
print_var m1
print_var m2

# datanode
slaves=$(../../bin/getconfig.sh hadoop.datanode.hostnames)

# QJM(Quorum Journal Manager)
#   number: 2*n+1
#   qjournal://ns1.spark.bi:8485;ns2.spark.bi:8485;ns3.spark.bi:8485/rt_cluster
journals=$(../../bin/getconfig.sh hadoop.journalnode.hostnames)
qjournal=$(echo $journals | sed 's/,/:8485,/g')":8485"

databasedirs=$(../../bin/getconfig.sh hadoop.datanode.databasedirs)
print_var databasedirs


#
# make conf
#

rm -rf conf; mkdir conf
cp conf.ha.template/* ./conf/

# TODO: hadoop 自己可以通过 ${var} 的形式来引用变量，但无法自己定义一个变量也这样引用

# give name, set new value
function set_conf_xml_property_value()
{
    file=./conf/$1
    name=$2
    value=$(echo $3 | sed 's/\//\\\//g')
    LOG DEBUG "update $file set $name to $3"

    # sed -i 's/VALUE_'$name'_VALUE/'$value'/' $file
    #
    sed -i '/<name>'$name'</,/<value>/ s/.*<value>.*/        <value>'$value'<\/value>/' $file
    # TODO: parse xml ...
}

# simplely symbol substitute
# var definition conf/*.xml: ${var-name}
function set_conf_xml_var()
{
    file=./conf/$1
    var=$2
    val=$(echo $3 | sed 's/\//\\\//g')
    LOG DEBUG "update $file replace $var to $3"
    sed -i 's/${'$var'}/'$val'/' $file
}


# core-site.xml
set_conf_xml_property_value core-site.xml ha.zookeeper.quorum  "$zk_quorum"
set_conf_xml_property_value core-site.xml hadoop.tmp.dir       "$data_dir/tmp-hadoop-\${user.name}"


# hdfs-site.xml
set_conf_xml_var hdfs-site.xml NAMENODE_1 ${m1}
set_conf_xml_var hdfs-site.xml NAMENODE_2 ${m2}

set_conf_xml_property_value hdfs-site.xml dfs.namenode.shared.edits.dir "qjournal://$qjournal/hacluster"
set_conf_xml_property_value hdfs-site.xml dfs.journalnode.edits.dir "${data_dir}/dfs.journalnode.edits.dir"
# WATCH:
# dfs.ha.fencing.ssh.private-key-files
# dfs.ha.fencing.methods

set_conf_xml_property_value hdfs-site.xml dfs.namenode.name.dir     "${data_dir}/dfs.namenode.name.dir"
set_conf_xml_property_value hdfs-site.xml dfs.datanode.data.dir     "${databasedirs}"


# conf/hadoop-env.sh
echo "
export JAVA_HOME=/usr/java/latest
export HADOOP_PREFIX=${CLUSTER_BASEDIR_INSTALL}/${CLUSTER_PROJECT_HADOOP_NAME}
export HADOOP_LOG_DIR=${CLUSTER_BASEDIR_LOG}/hdfs
" > conf/hadoop-env.sh


# conf/slaves
../../bin/getconfig.sh hadoop.datanode.hostnames \
| sed 's/[,;]/\n/g' | sort -u | grep -v '^$' \
> conf/slaves


# conf/yarn-env.sh
echo "
export JAVA_HOME=/usr/java/latest
export HADOOP_PREFIX=${CLUSTER_BASEDIR_INSTALL}/${CLUSTER_PROJECT_HADOOP_NAME}
export YARN_LOG_DIR=${CLUSTER_BASEDIR_LOG}/yarn
" > conf/yarn-env.sh


# yarn-site.xml
set_conf_xml_var yarn-site.xml NAMENODE_1 ${m1}
set_conf_xml_var yarn-site.xml NAMENODE_2 ${m2}

set_conf_xml_property_value yarn-site.xml yarn.resourcemanager.zk-address "$zk_quorum"



exit 0


# TODO: set ssh no pwd, from namenode to datanode


#

function install()
{
    host=$1

    ssh $host "mkdir -p ${CLUSTER_BASEDIR_INSTALL}"

    # copy pkg and un package
    scp ${CLUSTER_PACKAGE_DIR}/${CLUSTER_PROJECT_HADOOP_PKG_NAME} $host:${CLUSTER_BASEDIR_INSTALL}
    ssh $host "
      cd ${CLUSTER_BASEDIR_INSTALL};
      tar xf ${CLUSTER_PROJECT_HADOOP_PKG_NAME}
    "

    # conf
    scp -r conf/* $host:${CLUSTER_BASEDIR_INSTALL}/${CLUSTER_PROJECT_HADOOP_NAME}/conf/

    ssh $host "
        for d in ... ; do
            mkdir -p \$d
            chown -R $CLUSTER_USER  \$d
            chgrp -R $CLUSTER_GROUP \$d
        done
    "
}


{
  ../../bin/getconfig.sh hadoop.namenode.hostnames
  ../../bin/getconfig.sh hadoop.datanode.hostnames
} | sed 's/[,;]/\n/g' | sort -u | grep -v '^$' \
| while read host; do
    ip=$(../../bin/nametoip.sh $host)
    echo "install  $host($ip) ..."
    install $ip
done

fab_options=""
    pwd=$(get_pwd $host)
    port=$($DIR/getconfig.sh ssh_port)
    fab_options="--fabfile=$DIR/../env/fabfile.py --hosts=$ip:$port --password=$pwd"



#rm -rf conf
