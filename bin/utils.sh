#!/usr/bin/env bash

# basic tools


UTILDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $UTILDIR/../common/log.sh

# input: hostname
# output: root passwd
function get_pwd()
{
    host=$1
    v=`$UTILDIR/getconfig.sh root_passwd_$host`
    if [ -z "$v" ]; then
        $UTILDIR/getconfig.sh root_passwd_def
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
        echo "fab --fabfile=$UTILDIR/../env/fabfile.py $fab_options $cmd > tmp.fab.log 2>&1"
        #fab --fabfile=$UTILDIR/../env/fabfile.py $fab_options $cmd > tmp.fab.log 2>&1
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

