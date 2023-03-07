#!/usr/bin/env bash
arg_list=$*
sh create_library.sh -u -m -b   $arg_list
if [[ $? -eq 0 ]]; then
    sh create_library.sh -u -m -p  $arg_list
    sh create_image.sh -u -m -b  $arg_list
    sh create_image.sh -u -m -p  $arg_list
fi
