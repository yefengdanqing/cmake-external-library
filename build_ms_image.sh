#!/usr/bin/env bash
arg_list=$*
bash -x ./run_build_library.sh -a x86_64 -s unity
if [ $? -eq 0 ]; then
    bash -x run_build_images.sh -a x86_64 -s unity
fi
