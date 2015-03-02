#!/usr/bin/env bash

if [ `whoami` == "root" ]; then
    echo "MUST NOT run as root"
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "Usage: $0 {zookeeper|hadoop|spark} {start|stop|jps|...}"
    exit 0
fi

prj=$1
shift

if [ -d $prj ]; then
    cd $prj
    if [ -f admin_env.sh ]; then
        . admin_env.sh
    fi

    ./admin.sh $*
fi


