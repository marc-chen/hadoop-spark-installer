#!/usr/bin/env python
# -*- encoding:utf-8 -*-
"""
    author: marcchen, create: 2014-12-01
"""

from fabric.api import *



def set_pwd_less_ssh(user):
    """
    set password-less ssh to remote host as specified user
    """

    key_type = "rsa" # 必须 rsa, hadoop 配置文件 hdfs-site.xml 中的 dfs.ha.fencing.ssh.private-key-files 依赖 rsa

    local_hostname=local("""hostname""", capture=True)
    key_id="%s@%s" % (user, local_hostname)
    local_user_home=local("""grep "^%s:" /etc/passwd | cut -d':' -f6 """ % user, capture=True)
    print "local_user_home: " + local_user_home

    remote_user_home=run("su -c 'cd; pwd' %s" % user)
    remote_user_group=run("su -c 'groups' %s" % user)
    print "remote_user_home: %s %s" % (remote_user_home, run("whoami"))

    # gen key
    local("""
        if [ ! -f %s/.ssh/id_%s.pub ]; then
            su %s -c "ssh-keygen -t %s -P '' -f ~/.ssh/id_%s"
        fi
    """ % (local_user_home, key_type, user, key_type, key_type)
    )

    # put to remote
    pubfile = "id_%s.pub" % key_type
    put("%s/.ssh/%s" % (local_user_home, pubfile), remote_user_home)

    # Too violent
    #    if [ -f $home/.ssh/authorized_keys ]; then
    #        sed -i '/^ssh-%s .* %s$|^$/d' $home/.ssh/authorized_keys
    #    fi
    run("""
        home="%s"
    
        mkdir -p $home/.ssh;
    
        cat   $home/%s >> $home/.ssh/authorized_keys;
        mv    $home/%s $home/.ssh/pubkey_hadoop_inst;
    
        chown -R %s $home/.ssh
        chgrp -R %s $home/.ssh
    
        chmod 600 $home/.ssh/authorized_keys
        chmod 700 $home/.ssh
        """ % ( remote_user_home, pubfile, pubfile, user, remote_user_group )
    )



def _set_curusr_pwd_less_ssh():
    """
    set current user password-less ssh to remote host
    """

    #key_type = "dsa"
    key_type = "rsa" # 必须 rsa, hadoop 配置文件 hdfs-site.xml 中的 dfs.ha.fencing.ssh.private-key-files 依赖 rsa

    local("""
    if [ ! -f ~/.ssh/id_%s.pub ]; then
        ssh-keygen -t %s -P '' -f ~/.ssh/id_%s
    fi
    """ % ( key_type, key_type, key_type)
    )

    pubfile = "id_%s.pub" % key_type
    put("~/.ssh/%s" % pubfile, "~/")

    user=local("""whoami""", capture=True)
    hostname=local("""hostname""", capture=True)
    key_id="%s@%s" % (user, hostname)

    run("""
    mkdir -p ~/.ssh
    if [ -f ~/.ssh/authorized_keys ]; then
        sed -i '/^$/d' ~/.ssh/authorized_keys
        sed -i '/^ssh-%s .* %s$/d' ~/.ssh/authorized_keys
    fi
    pubfile=%s
    cat $pubfile >> ~/.ssh/authorized_keys
    rm $pubfile
    """ % (key_type, key_id, pubfile)
    )

