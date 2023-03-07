#!/usr/bin/env bash
arg_list=$*
sh create_library.sh -e -b $arg_list
if [[ $? -eq 0 ]]; then
    sh create_library.sh -e -p $arg_list
    sh create_image.sh -t  -b $arg_list
    sh create_image.sh -t -p $arg_list
fi
