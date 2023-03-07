#!/usr/bin/env bash
arg_list=$*
sh create_library.sh -t -m -b $arg_list
if [[ $? -eq 0 ]]; then
    sh create_library.sh -t -m -p $arg_list
    sh create_image.sh -t -m -b $arg_list
    sh create_image.sh -t -m -p $arg_list
fi
