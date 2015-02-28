#!/bin/bash

. common/log.sh

function usage()
{
    echo "Usage: $0 {zookeeper|hadoop}"
}

if [ $# -ne 1 ]; then
    usage
    exit 0
fi


case $1 in
    zookeeper|hadoop)
        ;;
    *)
        usage
        exit 1
esac



# set env for scripts after
. ./bin/set_env.sh



# TODO: check when installing the project
#    # check packages
#    sub_proc ./bin/chk_packages.sh 
#    LOG INFO "SUCCEED: check packages"




function install_proj()
{
    proj=$1
    echo
    LOG DEBUG "install $proj"
    echo
    cd ./projects/$proj
    ./install.sh
    # ./remove.sh
    cd -
}

# install zookeeper, hadoop
install_proj $1



# install mysql (single point)

# install spark

# check install


exit 0

