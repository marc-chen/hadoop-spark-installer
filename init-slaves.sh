#!/usr/bin/env bash

. common/log.sh
. common/util.sh


# set env for scripts after
. ./bin/set_env.sh


# init all slave machines, run after init-master


    # copy file to master machines, and run there
    
    # init hosts
    #   user,group
    #   base dir
    #   ssh no pwd
    #   install jdk
    #   hosts
    echo
    echo "Init hosts"
    echo
    sub_proc ./bin/init_hosts.sh
    LOG INFO "SUCCEED: init hosts"
    
    
    # check hosts
    #   ntp, time
    #   hostname
    #   ping hostname
    LOG INFO "TODO: check host if ready: ntp, network, ssh"
    
    
    # check root passwd

