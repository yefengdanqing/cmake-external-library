#!/usr/bin/env bash
arg_list=$*
sh create_library.sh -t -b -g $arg_list
if [[ $? -eq 0 ]]; then
    sh create_library.sh -t -p -g $arg_list
    sh create_image.sh -c -t -b  $arg_list
    sh create_image.sh -c -t -p  $arg_list
fi
