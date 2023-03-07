#!/usr/bin/env bash
arg_list=$*
sh create_library.sh -u -b -g  $arg_list
if [[ $? -eq 0 ]]; then
    sh create_library.sh  -u -p -g $arg_list
    sh create_image.sh -c -u -b  $arg_list
    sh create_image.sh -c -u -p $arg_list
fi
