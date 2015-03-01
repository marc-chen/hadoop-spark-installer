#!/usr/bin/env bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 all"
    exit 1
fi

. bin/utils.sh


function clearEnv()
{
    host=$1

    # ignore these:
    #   hostname
    #   /etc/hosts
    #   JAVA_HOME, jdk
    #   user, group

    # /root/.ssh
    ssh $host 'rm -rf /root/.ssh'
}

# 要删除的目录
declare -a arr_rm_dir
arr_i=0
cur_dir=`pwd`
for cf in basedir.install basedir.log basedir.data; do
    dir=$(./bin/getconfig.sh $cf)
    # 忽略当前目录，避免误删
    if [ `echo $dir | grep -a -i $cur_dir | wc -l` -gt 0 ]; then
        echo "ignore dir same to current: $dir"
    else
        echo "will rm dir $dir"
        arr_rm_dir[$arr_i]="$dir"
        arr_i=$((arr_i + 1))
    fi
done
# 再次确认，避免误操作
echo -n "clean all dir about, sure? (y/n):"
read p
if [ $p != "y" ]; then
    exit 0
fi



for host in $(getallhostip); do

    echo "> remove $host ..."

    # 1. kill java process
    echo "  > kill java process"
    ssh $host "ps aux | grep java | awk '{print \$2}' | xargs kill -9"

    # 2. project dir
    echo "  > rm base dir"
    for dir in ${arr_rm_dir[*]}; do
        ssh $host "rm -rf $dir"
    done

    # last: env
    echo "  > clean env"
    clearEnv $host

    echo
done

