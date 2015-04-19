#!/usr/bin/env bash

# init all masters: set pwd-less ssh from all master to all slaves

. common/log.sh
. common/utils.sh
. ./bin/utils.sh


slaves=$(./bin/getconfig.sh hadoop.datanode.hostnames)
slaves="$slaves $(./bin/getconfig.sh spark.slave.hostnames)"
slaves=`echo "$slaves" | sed 's/[,; ]/\n/g' | sort -u | grep -v '^$'`

user=$(./bin/getconfig.sh run.user)

echo "slave: $slaves";
echo "user: $user";

for m in $(get_all_master_ip); do
    for s in $slaves; do
        echo $m $s
        sip=$(./bin/nametoip.sh $s)
        sub_proc ./env/set_pwd_less_ssh_fromA_toB.sh $m $sip $user
    done
    LOG INFO "init master $m done";
done


