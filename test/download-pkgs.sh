#!/usr/bin/env bash

mkdir -p ../packages

url=http://10.166.142.210:8085

for pkg in `grep '^package' ../conf/config | awk '{print $NF}'`; do
    echo $pkg

    if [ ! -f ../packages/$pkg ]; then
        wget -O ../packages/$pkg $url/$pkg
    fi
    
done

