#!/bin/bash

set -e
set -x

export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")

source ${BASEDIR}/docker/VERSIONS
function help_usage() {
    echo "sh $0 -a(rch) -c(gcc_version) -g(gpu_image) -b[uild] -p[ush]"
}

function get_docker_image() {
    local docker_url=$1
    local docker_name=$2
    local docker_tag=$3
    printf "%s/%s:%s" $docker_url $docker_name $docker_tag
}
function build_image_internal() {
    local base_image=$1
    local output_image=$2
    local external_file_name=$3
    docker build -f docker/Dockerfile_ml_platform_dev -t ${output_image} \
        --build-arg thirdparty_build_image_tag=${base_image}             \
        --build-arg external_url=${EXTERNAL_URL}/${external_file_name}    \
        --build-arg external_file_name=${external_file_name} .
}
function push_docker_image_byname() {
    local output_docker_name=$1
    local output_docker_tags=$2
    local output_image=$(get_docker_image ${ML_THIRDPARTY_BUILD_DOCKER_URL} ${output_docker_name} ${output_docker_tags})
    docker push $output_image
}
function build_image_base_on_gcc_os() {
    local output_docker_name=$1
    local output_docker_tags=$2
    local base_image=$3
    local build_name=$4
    local system_arch=$5
    local gcc_version=$6

    local output_image=$(get_docker_image ${ML_THIRDPARTY_BUILD_DOCKER_URL} ${output_docker_name} ${output_docker_tags})
    local build_name=$build_name-${gcc_version}
    local external_version=${EXTERNAL_VERSION}
    local external_file_name="ml-platform-${build_name}-RelWithDebInfo-${external_version}.tar.bz2"
    build_image_internal $base_image $output_image ${external_file_name}
}
function build_and_push_image() {
    local  is_3rdparty_image=0
    local  is_unity_image=0
    local  is_gpu_image=0
    local  build_op=0
    local  push_op=0
    while getopts a:bc:go:ptuh OPTION
    do
       case ${OPTION} in
            h) help_usage
                exit 1
                ;;
            a) arch=$OPTARG
                ;;
            b) build_op=1
            ;;
            c) gcc_version=$OPTARG
                ;;
            o) os_system=${OPTARG}
                ;;
            g) is_gpu_image=1
                ;;
            p) push_op=1
                ;;
            t) is_3rdparty_image=1
                ;;
            u) is_unity_image=1
                ;;
        esac
   done
   if [ -z $arch ] || [ -z $gcc_version ]; then
       echo "arch or gcc_version is null"
       exit
   fi
   system_arch=$(echo $os_system-$arch)
   if [ $is_3rdparty_image -eq 1 ]; then
       docker_name=$(echo $ML_THIRDPARTY_GCC_BUILD_DOCKER_NAME)
       docker_tags=$(printf $ML_THIRDPARTY_GCC_BUILD_DOCKER_TAG  $system_arch-gcc$gcc_version-cpu)
       build_name="3rdparty-cpu"
   elif [[ $is_unity_image -eq 1 ]];then
       docker_name=$(echo $ML_UNITY_GCC_DOCKER_NAME)
       docker_tags=$(printf $ML_UNITY_GCC_DOCKER_TAG $system_arch-gcc$gcc_version-cpu)
       build_name="unity-cpu"
   fi
   if [ $build_op -eq 1 ]; then
       if [ $is_3rdparty_image -eq 1 ]; then
           gcc_os_docker_name=$(printf $ML_GCC_OS_BUILD_DOCKER_NAME $system_arch-cpu-base)
       else
           #gcc_os_docker_name=$(printf $ML_GCC_OS_BUILD_DOCKER_NAME $system_arch-gcc${gcc_version}-cpu)
           gcc_os_docker_name=$(printf $ML_GCC_OS_BUILD_DOCKER_NAME $system_arch-cpu-base)
       fi
       base_image=$(get_docker_image ${ML_OS_BUILD_DOCKER_URL} ${gcc_os_docker_name} ${ML_GCC_OS_BUILD_DOCKER_TAG})
   fi
   if [ $is_gpu_image -eq 1 ]; then
       docker_name=$(echo ${docker_name} | sed 's/cpu/gpu/g')
       docker_tags=$(echo ${docker_tags} | sed 's/cpu/gpu/g')
       build_name=$(echo ${build_name} | sed 's/cpu/gpu/g')
       base_image=$(echo ${base_image} | sed 's/cpu/gpu/g')
   fi
   if [ $build_op -eq 1 ]; then
       build_image_base_on_gcc_os $docker_name $docker_tags $base_image $build_name $system_arch $gcc_version
   fi
   if [ $push_op -eq 1 ]; then
       push_docker_image_byname $docker_name $docker_tags
   fi
}
build_and_push_image $*
