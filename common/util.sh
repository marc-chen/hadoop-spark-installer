#!/usr/bin/env bash


# for script that call fab function
function sub_proc()
{
    $*
    if [ $? -ne 0 ]; then
        # clean
        exit 1
    fi
}

