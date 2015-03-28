#!/bin/bash

# 配置本机 ssh 到目标机器不需要密码登录
# 默认是账号 root，也可以指定其它用户名
# 过程中一般需要输入账号密码

if [ $# -lt 1 ] || [ $# -gt 2 ]; then
    echo "Usage: $0 DST_IP [ user ]"
    exit 1
fi

{

host=$1
user="root"

if [ $# -eq 2 ]; then
    user="$2"
fi

echo "> set ssh password-less login to $host as $user"


# echo "testing ..."
sudo -u $user ssh -o NumberOfPasswordPrompts=0 -o StrictHostKeyChecking=no $host 'echo OK'
if [ $? -eq 0 ]; then
    echo "ssh root to $host without password OK"
    exit 0
fi


user_home=`grep "^$user:" /etc/passwd | cut -d':' -f6`

type="rsa"

    if [ ! -f $user_home/.ssh/id_$type.pub ]; then
        sudo -u $user ssh-keygen -t $type -P '' -f ~/.ssh/id_$type
    fi

sudo -u $user scp ~/.ssh/id_$type.pub $host:~/
sudo -u $user ssh $host "cd; mkdir -p .ssh; cat id_${type}.pub >> .ssh/authorized_keys; rm id_$type.pub"

echo "set ssh root to $host without password OK"

} &
wait

