#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
echo $DIR

. $DIR/common/log.sh

. $DIR/bin/utils.sh


{
    $DIR/bin/getconfig.sh hadoop.datanode.hostnames
    $DIR/bin/getconfig.sh spark.slave.hostnames
} \
| sed 's/[,;]/\n/g' | sort -u | grep -v '^$' \
| while read host; do

    ip=$($DIR/bin/nametoip.sh $host)
    pwd=$(get_pwd $host)
    user=$($DIR/bin/getconfig.sh run.user)
    group=$($DIR/bin/getconfig.sh run.group)
    port=$($DIR/bin/getconfig.sh ssh_port)

    LOG DEBUG "set password-less ssh to $host($ip:$port) as $user"

    which fab > /dev/null
    if [ $? -ne 0 ]; then
        # if fab not installed, use shell
        {
            $DIR/env/set_ssh_no_pwd.sh $ip $user $group
        }&
        wait
    else
        fab_options="--fabfile=$DIR/env/fab_pwd_less_ssh.py --hosts=$ip:$port --password=$pwd"
        fab_command "set_pwd_less_ssh:user=$user"
    fi

done


