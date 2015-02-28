#!/usr/bin/env bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 {zookeeper|hadoop|spark} {start|stop}"
    exit 0
fi

prj=$1
act=$2

echo TODO $prj $act

