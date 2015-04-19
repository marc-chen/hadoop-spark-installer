#!/usr/bin/env bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 ip hostname"
    exit 1
fi

ip=$1
host=$2


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/../common/log.sh
. $DIR/utils.sh



fab_options=""


echo
LOG DEBUG "init host $host($ip) ..."
echo

    # ip=$(./nametoip.sh $host)


    pwd=$(get_pwd $host)
    port=$($DIR/getconfig.sh ssh_port)


    if [ -z "$ip" ] || [ -z "$port" ] || [ -z "$pwd" ]; then
        LOG ERROR "get ip,post,pwd of $host failed: ($ip:$post, $pwd)"
        exit 1
    fi

    fab_options="--fabfile=$DIR/../env/fabfile.py --hosts=$ip:$port --password=$pwd"


    # add user, group
    user=$($DIR/getconfig.sh run.user)
    group=$($DIR/getconfig.sh run.group)
    fab_command "add_user_group:user=$user,group=$group" "add usergroup for $host[$ip]"


    # base dir
    dir=$($DIR/getconfig.sh basedir.install)
    fab_command "init_base_dir:dir=$dir,user=$user,group=$group" "init basedir $dir for $host[$ip]"
    dir=$($DIR/getconfig.sh basedir.log)
    fab_command "init_base_dir:dir=$dir,user=$user,group=$group" "init basedir $dir for $host[$ip]"
    dir=$($DIR/getconfig.sh basedir.data)
    fab_command "init_base_dir:dir=$dir,user=$user,group=$group" "init basedir $dir for $host[$ip]"


    # JDK
    jdk_pkg=$($DIR/getconfig.sh package.jdk)
    pkg_dir="$DIR/../packages"
    jdk_ver=`tar tf $pkg_dir/$jdk_pkg | head -1 | grep -Po '\d[^/]*'`
    fab_command "install_jdk_tar:tarpath=$pkg_dir/$jdk_pkg,ver=$jdk_ver" "install jdk $jdk_ver for $host[$ip]"


    # TODO: ntp
    LOG DEBUG "TODO: add ntpupdate to crontab"


    LOG INFO "SUCCEED: init host $host($ip)"


echo
