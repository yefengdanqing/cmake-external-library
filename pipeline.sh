#!/usr/bin/env bash
function build_base_images() {
    local arch=$1
    bash -x ./build_centos_build_image.sh -x $arch
}
function build_application_images() {
    stage=$1
    version=$2
    shift 2
    arch_list=$*
    if [ -z $version ]; then
        echo "version should not empty"
        exit -1
    fi
    for iarch in ${arch_list[@]}
    do
      echo $iarch
    done
    for iarch in ${arch_list[@]}
    do
        bash -x run_build_library.sh -a $iarch -s $stage -v $version
        if [ $? -eq 0 ]; then
            bash -x run_build_images.sh  -a $iarch -s $stage -v $version
            break
        fi
    done
}
function build_3rdparty_images() {
    build_application_images 3rdparty $version $*
}
function build_unity_images() {
    build_application_images unity $version $*
}
function check_status() {
    local status=$1
    shift 1
    if [ $status -ne 0 ]; then
        echo "$status return $*"
        exit -1
    fi
}
function help_usage() {
  echo "usage script -base -thirdparty -gpu -unity"
}
function build_all_image() {
    arch=$(arch)
    enable_base=0
    enable_gpu=0
    enable_3rdparty=0
    enable_unity=0
    repo_version="master"
    while getopts bgtuv:h OPTION
    do
       case ${OPTION} in
            h) help_usage
               exit 1
                ;;
            b) enable_base=1
                ;;
            g) enable_gpu=1
                ;;
            t) enable_3rdparty=1
                ;;
            u) enable_unity=1
                ;;
            v) repo_version=$OPTARG
                ;;
            s) stage=$OPTARG
                ;;
        esac
    done
    version=$repo_version
    if [ $enable_base -gt 0 ]; then
        images=${arch}
        if [ ${enable_gpu} -gt 0 ];then
          images=${images}-gpu
        fi
        build_base_images  $images
        check_status $? "fail build_base_images with ${images}"
    fi
    if [ ${enable_3rdparty} -gt 0 ]; then
        images=${arch}
        if [ ${enable_gpu} -gt 0 ];then
          images=${images}-gpu
        fi
        build_3rdparty_images ${images}
        check_status $? "fail build_3rdparty_images $images"
    fi
    if [ ${enable_unity} -gt 0 ]; then
        images=${arch}
        if [ ${enable_gpu} -gt 0 ];then
          images=${images}-gpu
        fi
        build_unity_images ${images}
        check_status $? "fail build_unity_images ${images}"
    fi
}
build_all_image $*
