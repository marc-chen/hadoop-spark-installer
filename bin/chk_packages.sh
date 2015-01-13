#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. $DIR/../common/log.sh

pkg_dir="$DIR/../packages"

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

for p in sdk hadoop zookeeper spark; do
    v=`$DIR/getconfig.sh package.$p`
    if [ ! -f $pkg_dir/$v ]; then
        LOG ERROR "$p package $pkg_dir/$v not exists, download url: $(pkg_url $p)"
        exit 1
    fi
    LOG INFO "$p package check OK: $v"
done

exit 0
