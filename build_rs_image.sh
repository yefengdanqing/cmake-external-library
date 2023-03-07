#!/usr/bin/env bash
arg_list=$*
sh create_library.sh -u  -b   $arg_list
if [[ $? -eq 0 ]]; then
    sh create_library.sh  -u -p  $arg_list
    sh create_image.sh -u -b  $arg_list
    sh create_image.sh -u -p  $arg_list
fi
