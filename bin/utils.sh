#!/usr/bin/env bash

# basic tools


UTIL_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $UTIL_DIR/../common/log.sh

# input: hostname
# output: root passwd
function get_pwd()
{
    host=$1
    v=`$UTIL_DIR/getconfig.sh root_passwd_$host`
    if [ -z "$v" ]; then
        $UTIL_DIR/getconfig.sh root_passwd_def
    fi
}

# run a fab command
#
fab_options=""
#
# input 1: fab command
# input 2: comment
function fab_command()
{
    cmd="$1"
    msg="$2"

    {
        echo "fab --fabfile=$UTIL_DIR/../env/fabfile.py $fab_options $cmd > tmp.fab.log 2>&1"
        #fab --fabfile=$UTIL_DIR/../env/fabfile.py $fab_options $cmd > tmp.fab.log 2>&1
        fab $fab_options $cmd > tmp.fab.log 2>&1
    } &
    pid=$!
    wait $pid
    if [ $? -ne 0 ]; then
        LOG ERROR "FAILED: $msg"
        exit 1
    fi
    LOG INFO "SUCCEED: $msg"
}

function print_var()
{
    k=$1
    v=$(eval echo "\$$k")
    echo -e "$k\t$v"
}



function getallhostip()
{
    grep -P '^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)' $UTIL_DIR/../conf/hosts \
    | awk 'NF==2{print $1}' | sort -u
}



function get_all_master_hostname()
{
  {
    $UTIL_DIR/getconfig.sh zookeeper.hostnames;
    $UTIL_DIR/getconfig.sh hadoop.namenode.hostnames;
    $UTIL_DIR/getconfig.sh spark.master.hostnames;
  } | sed 's/[,;]/\n/g' | sort -u | grep -v '^$'
}

function get_all_master_ip()
{
    get_all_master_hostname | $UTIL_DIR/nametoip.sh
}


# auto select use fab or not
function set_ssh_pwd_less_login()
{
    host=$1
    user=$2

    ip=$($UTIL_DIR/nametoip.sh $host)
    port=$($UTIL_DIR/getconfig.sh ssh_port)
    pwd=$(get_pwd $host)

    echo "> set password-less ssh to $host($ip:$port) as $user"

    which fab > /dev/null
    if [ $? -ne 0 ]; then
        # if fab not installed, use shell
        {
            $UTIL_DIR/../env/set_ssh_no_pwd.sh $ip $user
        }&
        wait
    else
        fab_options="--fabfile=$UTIL_DIR/../env/fab_pwd_less_ssh.py --hosts=$ip:$port --password=$pwd"
        fab_command "set_pwd_less_ssh:user=$user" "set pwdless user $user for $host[$ip]";
    fi
    ssh -o StrictHostKeyChecking=no $ip pwd #> /dev/null 2>&1
}


