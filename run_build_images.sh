#!/usr/bin/env bash
function build_3rdparty_image() {
    local arch=$1
    local os=$2
    local gcc_ver=$3
    shift 3
    args_list="-b -p"
    echo $arch | grep gpu
    if [ $? -eq 0 ]; then
        args_list="$args_list -g"
        # remove -gpu suffix
        arch=$(echo $arch | awk -F'-' '{print $1}')
    fi

    bash -x ./build_image_common.sh -a $arch -o $os -c $gcc_ver -t $args_list $*
}
function build_unity_image() {
    local arch=$1
    local os=$2
    local gcc_ver=$3
    shift 3
    args_list="-b -p"
    echo $arch | grep gpu
    if [ $? -eq 0 ]; then
        args_list="$args_list -g"
        # remove -gpu suffix
        arch=$(echo $arch | awk -F'-' '{print $1}')
    fi

    bash -x ./build_image_common.sh -a $arch -o $os -c $gcc_ver -u $args_list $*
}
function help_usage() {
    echo "usage -a x86_64|aarch64|x86_64-gpu -s 3rdparty|unity -v gcc"
}
function build_image_wrapper() {
    local arch=""
    local stage=""
    local repo_version="master"
    while getopts a:v:s:h OPTION
    do
       case ${OPTION} in
            h) help_usage
               exit 1
                ;;
            a) arch=$OPTARG
                ;;
            v) repo_version=$OPTARG
                ;;
            s) stage=$OPTARG
                ;;
        esac
    done
    if [ -z $stage ] || [ -z $arch ]; then
        echo "stage $stage arch $arch"
        exit
    fi
    ## do-check
    arch_list="x86_64 aarch64"
    stage_list="3rdparty unity"
    declare -A os_list=(["x86_64"]="centos7"
                        ["x86_64-gpu"]="centos7"
                        ["aarch64"]="centos7"
                        ["aarch64-gpu"]="centos7"
                        ["os8-aarch64"]="centos8")
    declare -A gcc_list=(["x86_64"]="10.2.1"
                         ["x86_64-gpu"]="7.3.1"
                         ["aarch64"]="10.2.1"
                         ["aarch64-gpu"]="7.3.1"
                         ["os8-aarch64"]="10.3.1")
    build_${stage}_image $arch ${os_list[$arch]} ${gcc_list[$arch]}
}
build_image_wrapper $*
