#!/bin/bash

. common/log.sh
. common/utils.sh
. bin/utils.sh

function usage()
{
    echo "Usage: $0 {all|zookeeper|hadoop}"
}

if [ $# -ne 1 ]; then
    usage
    exit 0
fi


# set base env for scripts following
. ./bin/set_env.sh


function install_proj()
{
    proj=$1
    echo
    LOG DEBUG "install $proj"
    echo

    cd ./projects/$proj

    # default admin_env.sh
    {
        echo "# env shared by all projects"
        echo "export SSH_OPTS='${SSH_OPTS}'"
        echo "export CLUSTER_USER=${CLUSTER_USER}"
        echo "export CLUSTER_GROUP=${CLUSTER_GROUP}"
        echo
    } > admin_env.sh

    ./install.sh
    # ./remove.sh
    cd -
}


function install_all()
{
    # set ssh root pwd-less to all
    for ip in $(getallhostip); do
        set_ssh_pwd_less_login $ip root root
    done
    echo

    # set hostname of all machines
    ./bin/init_hostnames.sh
    echo

    # copy to other master
    work_dir="/tmp/spark-installer"
    rm -f ${work_dir}.tar.gz
    tar --exclude packages --exclude .git -zcvf ${work_dir}.tar.gz .
    for host in $(get_all_master_hostname); do
        ssh $SSH_OPTS $host "rm -rf ${work_dir}; mkdir ${work_dir}"
        scp $SSH_OPTS -v ${work_dir}.tar.gz $host:${work_dir}
        ssh $SSH_OPTS $host "cd ${work_dir}; tar xvf *.tar.gz"
        echo
    done
    echo


    # init master
    for host in $(get_all_master_hostname); do
        echo "> init $host as master"
        ssh $SSH_OPTS $host "cd ${work_dir}; ./init-master.sh"
        echo
    done

    echo "> init all host base env"
    ./init-all.sh

# install project

    # install_proj zookeeper
    # install_proj hadoop

# remove ssh root pwd-less to all

}





# TODO: check when installing the project
#    # check packages
#    sub_proc ./bin/chk_packages.sh 
#    LOG INFO "SUCCEED: check packages"


# install zookeeper, hadoop
case $1 in
    all)
        install_all
        ;;
    zookeeper|hadoop)
        install_proj $1
        ;;
    *)
        usage
        exit 1
esac



# install mysql (single point)

# install spark

# check install


# copy admin.sh to install-base-dir


for host in $(get_all_master_hostname); do
    scp $SSH_OPTS -v projects/admin.sh $host:${CLUSTER_BASEDIR_INSTALL}
done


exit 0

