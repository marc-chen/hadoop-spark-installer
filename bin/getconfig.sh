#!/usr/bin/env bash

#
# 查询 conf/config 接口
#

if [ $# -ne 1 ]; then
    echo "Usage: $0 config_key"
    exit 1
fi

key=$1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
conf_file="$DIR/../conf/config"

v=`grep '^[ \t]*'$key'[ \t]*=' $conf_file | cut -d'=' -f2 | sed 's/^[ \t]*//' | sed 's/[ \t]*$//' | head -1`


# make sure everythin returned is meanable

case $key in
    "run.user")
        # TODO: set default value if empty
        echo $v
        ;;
    "run.group")
        if [ -z "$v" ]; then
            echo "users"
        else
            echo $v
        fi
        ;;
    *)
        echo $v
        exit 0
esac

