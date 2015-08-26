#!/usr/bin/env python
# -*- encoding:utf-8 -*-
"""
"""

"""
    author: marcchen, create: 2014-12-01
"""


from fabric.api import *



def pwd():
    run("pwd")


def add_user_group(user='hdfs', group='cluster'):
    """
    add user and group, usage: add_user_group:user=hdfs,group=users
    """
    run("""
    user="%s"
    grp="%s"
    if [ `grep "^$grp:" /etc/group | wc -l` -eq 0 ]; then
        groupadd $grp
    fi
    if [ `grep "^$user:" /etc/passwd | wc -l` -eq 0 ]; then
        useradd --shell /bin/bash -m -g $grp $user
    fi
    if [ `su $user -c 'groups'` != "$grp" ]; then
        usermod -g $grp $user
    fi
    #usermod -a -G $grp root
    #cp /root/.vimrc  /home/hdfs/
    home=`grep "^$user:" /etc/passwd | cut -d':' -f6`
    mkdir -p $home
    echo home: $home
    chown -R $user $home
    chgrp -R $grp  $home
    """
    % (user, group)
    )


def init_base_dir(dir, user, group):
    run("""
    dir="%s"
    user=%s
    grp=%s

    mkdir -p        $dir
    chown -R $user  $dir
    chgrp -R $grp   $dir
    chmod g+w       $dir

    """
    % (dir, user, group))


def clean_ssh_no_pwd():
    run("""
    for dir in /root /home/hbase /home/hdfs /home/spark /home/yarn /home/zookpr; do
        rm -rfv $dir/.ssh 
    done
    """)


def set_pwd_less_ssh(user, group):

    """
    su <USER> -c "ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa"
    su <USER> -c "ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa"
    """

    if user == "root":
        group = "root"

    user_home = "/root" if user == "root" else "/home/%s" % user

    #type = "dsa"
    type = "rsa" # 必须 rsa, hadoop 配置文件 hdfs-site.xml 中的 dfs.ha.fencing.ssh.private-key-files 依赖 rsa

    local("""
    if [ ! -f %s/.ssh/id_%s.pub ]; then
        su %s -c "ssh-keygen -t %s -P '' -f ~/.ssh/id_%s"
    fi
    """ % (user_home, type, user, type, type)
    )

    pubfile = "id_%s.pub" % type
    put("%s/.ssh/%s" % (user_home, pubfile), user_home)

    run("""
    home="%s"

    mkdir -p $home/.ssh;
    cat   $home/%s >> $home/.ssh/authorized_keys;
    rm    $home/%s;

    sort -u $home/.ssh/authorized_keys > $home/.ssh/authorized_keys.tmp
    mv $home/.ssh/authorized_keys.tmp $home/.ssh/authorized_keys

    chown -R %s $home/.ssh
    chgrp -R %s $home/.ssh

    cd $home/.ssh
    chmod 600 authorized_keys
    chmod 700 .
    chmod 755 ..
    """ % ( user_home, pubfile, pubfile, user, group )
    )


#def set_root_ssh_no_pwd():
#    _set_user_ssh_no_pwd('root')
#def set_hdfs_ssh_no_pwd():
#    _set_user_ssh_no_pwd('hdfs')



# 
#def _set_alluser_ssh_no_pwd():
#    """
#    set root, hdfs
#    """
#    set_root_ssh_no_pwd()
#    _set_user_ssh_no_pwd('hdfs')



# 放弃，ubuntu 默认没有安装 rpm
def install_jdk_rpm(rpmpath, ver):
    #pkg="jdk-7u65-linux-x64.rpm"
    with cd( '/tmp/' ):
        #上传文件
        v=run(""" java -version 2>&1 | head -1 | awk '{print $3}' | cut -d'"' -f2 """)
        if v == ver:
            print "jave %s already installed" % ver
            run("java -version")
            return

        put(rpmpath, '.')
        run("""
            pkg=`basename %s`
            rpm -ivh --force $pkg
            rm -f $pkg
        """ % (rpmpath)
        )
        run("""
        rc=/etc/profile

        if [ `grep "^export JAVA_HOME=" $rc | wc -l` -eq 0 ]; then
            echo "export JAVA_HOME=/usr/java/latest" >> $rc
        fi;
        """)

    run("""
        if [ ! -f /usr/bin/jps ] && [ -f /usr/java/default/bin/jps ];
            then ln -s /usr/java/default/bin/jps /usr/bin/jps;
        fi
    """)



# TODO: set installing path
def install_jdk_tar(tarpath, ver):
    #pkg="/tmp/jdk-7u65-linux-x64.tar.gz"
    with cd( '/tmp/' ):

        # check if have installed
        v=run("""
        if [ -f $JAVA_HOME/bin/java ]; then
            $JAVA_HOME/bin/java -version 2>&1 | head -1 | awk '{print $3}' | cut -d'"' -f2
        fi
        """)
        print "old ver: " + v

        if v == ver:
            print "jave version %s already installed" % ver
            return

        #上传文件
        put(tarpath, '.')

        # tar xf, create link
        run("""
            pkg=`basename %s`
            tar xf $pkg
            jdkdir=`tar tf $pkg | head -1 | cut -d '/' -f1`
            rm -f $pkg

            mkdir -p /usr/java/
            mv $jdkdir /usr/java/
            rm -f /usr/java/latest /usr/java/default
            ln -s /usr/java/$jdkdir /usr/java/latest
            ln -s /usr/java/latest /usr/java/default
        """ % (tarpath)
        )

        # set JAVA_HOME
        run("""
        rc=/etc/profile

        if [ `grep "^export JAVA_HOME=" $rc | wc -l` -eq 0 ]; then
            echo "export JAVA_HOME=/usr/java/latest" >> $rc
        fi;
        """)

        # link
        run("""
        for bin in java javac jps jar; do
            rm -f /usr/bin/$bin
            ln -s /usr/java/default/bin/$bin /usr/bin/$bin
        done
        """)



# crontab 前 3 行出现 ntpdate 就删除
# 把新的放到第2行前面
def ntpdate():
    run("""

    # find if exist /usr/sbin/ntpdate
    {
    line_no=`crontab -l | sed 's/^#.*//' | grep -n '/usr/sbin/ntpdate' | head -1 | cut -d':' -f1`

    # if no, insert ahead
    if [ -z "$line_no" ]; then

        echo 
        echo "# `date +"%F %T"` auto added by marcchen "
        echo '13,43 * * * *    sleep `perl -e "print int(rand(180))"`; /usr/sbin/ntpdate 10.224.132.241 10.192.144.168 10.169.136.81 10.192.144.171 10.161.130.183 > /dev/null 2>&1'
        echo
        crontab -l 

    # replace cur ver
    else

        a=$((line_no-2))
        if [ $a -gt 0 ]; then
            crontab -l | head -$a 
        fi

        a=$((line_no-1))
        crontab -l | head -$a | tail -1 | grep -v 'auto added by marcchen'

        echo "# `date +"%F %T"` auto added by marcchen "
        echo '13,43 * * * *    sleep `perl -e "print int(rand(180))"`; /usr/sbin/ntpdate 10.224.132.241 10.192.144.168 10.169.136.81 10.192.144.171 10.161.130.183 > /dev/null 2>&1'

        b=$((line_no+1))
        crontab -l | sed -n $b',$p'
    fi
    } | uniq | cat -s > ~/tmp.crontab

    crontab ~/tmp.crontab
    # rm ~/tmp.crontab

    """)

    run("/usr/sbin/ntpdate 10.224.132.241 10.192.144.168 10.169.136.81 10.192.144.171 10.161.130.183")



# append hosts info to /etc/hosts
# 按host删除比较好，会有一个ip多个host的情况
def append_to_etc_hosts(hosts_file):
    put(hosts_file, '/tmp')
    with cd( '/tmp/' ):
        run("""
        file=`basename %s`
        grep -P '^((2[0-4]\d|25[0-5]|[01]?\d\d?)\.){3}(2[0-4]\d|25[0-5]|[01]?\d\d?)' $file \
        | awk 'NF==2{print $0}' | while read ip host; do
            sed -i "/[ \t]\+$host[ \t]*$/d" /etc/hosts
            echo "$ip $host" >> /etc/hosts
        done
        rm $file
        """ % hosts_file)

    # nscd 是 DNS 缓存服务，对于集群来说提升不大，反而发现会影响 /etc/hosts 中的解析，所以停掉
    run("""
    {
        service nscd stop; chkconfig nscd off
        echo
    } > /dev/null 2>&1
    """)



# 调用方法：fab set_hostname:host=xxx,name=xxx
def set_hostname(name):
    run("""
IP="%s"
NAME="%s"
echo "IP: $IP, new hostname: $NAME"
hostname $NAME
# for centos
if [ -f /etc/sysconfig/network ]; then
    sed -i 's/^HOSTNAME=.*/HOSTNAME='"$NAME"'/' /etc/sysconfig/network
fi
# for ubuntu
if [ -f /etc/hostname ]; then
    echo $NAME > /etc/hostname
fi
sed -i 's/^127.0.0.1.*/127.0.0.1       localhost/' /etc/hosts
sed -i "/^$IP[ \t]/d" /etc/hosts
echo "$IP $NAME" >> /etc/hosts

hostname
cat /etc/hosts
    """ % (env.host, name)
    )



def init_new_cluster_client():
    """
    add client machine, NOTICE: install_jdk_7u65 if needed
    """
    cluster_add_user_hdfs_grp_cluster()
    cluster_init_shared_dir()
    set_alluser_ssh_no_pwd()
    cluster_set_etc_hosts()
    ntpdate()


