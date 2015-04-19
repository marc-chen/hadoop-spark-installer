#!/usr/bin/env bash

# set hostname for hosts at conf/hosts

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../common/log.sh
. $DIR/utils.sh

{

grep -P '^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)' $DIR/../conf/hosts | awk 'NF==2{print $0}' \
| while read ip host; do

    LOG DEBUG "set $ip hostname to $host"

    pwd=$(get_pwd $host)
    port=$($DIR/getconfig.sh ssh_port)
    # ip=$(./nametoip.sh $host)

    #if [ -z "$ip" ] || [ -z "$port" ] || [ -z "$pwd" ]; then
    #    LOG ERROR "get ip,post,pwd of $host failed: ($ip:$post, $pwd)"
    #    exit 1
    #fi

    fab_options="--fabfile=$DIR/../env/fabfile.py --hosts=$ip:$port --password=$pwd"

    fab_command "set_hostname:name=$host" "set $ip hostname to $host"

    # append hosts to /etc/hosts
    fab_command "append_to_etc_hosts:hosts_file=$DIR/../conf/hosts" "append to /etc/hosts $ip->$host"

done

} &
wait

