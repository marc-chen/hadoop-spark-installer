#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../common/log.sh


function pkg_url()
{
    case $1 in
        hadoop)
            echo "http://www.apache.org/dyn/closer.cgi/hadoop/common/"
            ;;
        *)
            echo "TODO"
            break
            ;;
    esac
}

for p in jdk hadoop zookeeper spark; do
    v=`$DIR/getconfig.sh package.$p`
    LOG DEBUG "check ${CLUSTER_PACKAGE_DIR}/$v"
    if [ ! -f ${CLUSTER_PACKAGE_DIR}/$v ]; then
        LOG ERROR "$p package ${CLUSTER_PACKAGE_DIR}/$v not exists, download url: $(pkg_url $p)"
        exit 1
    fi
    LOG INFO "$p package check OK: $v"

    # TODO: check md5
done

exit 0
