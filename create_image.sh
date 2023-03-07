#!/bin/bash

set -e
set -x

export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")

source ${BASEDIR}/docker/VERSIONS

DOCKER_URL=$ML_DEV_DOCKER_URL
DOCKER_TAG=$ML_DEV_DOCKER_TAG
function get_docker_image() {
    local docker_url=$1
    local docker_name=$2
    local docker_tag=$3
    printf "%s/%s:%s" $docker_url $docker_name $docker_tag
}
function build_image_internal() {
    local base_images=$1
    local output_images=$2
    local build_name=$3
    local external_version=$4
    local external_file_name="ml-platform-${build_name}-RelWithDebInfo-${external_version}.tar.bz2"
    if [ -f $external_file_name ]; then
        file_schema="file"
    else
        file_schema="aws"
    fi
    docker build -f docker/Dockerfile_ml_platform_dev -t ${output_images} \
        --build-arg thirdparty_build_image_tag=${base_images}             \
        --build-arg external_url=${EXTERNAL_URL}/${external_file_name}    \
        --build-arg external_file_name=${external_file_name} .
}
function build_dev_image() {
    local base_images=$(get_docker_image ${ML_THIRDPARTY_BUILD_DOCKER_URL} ${ML_THIRDPARTY_BUILD_DOCKER_NAME} ${ML_THIRDPARTY_BUILD_DOCKER_TAG})
    local output_images=$(get_docker_image ${DOCKER_URL} ${ML_DEV_DOCKER_NAME} ${DOCKER_TAG})
    build_image_internal $base_images $output_images dev ${EXTERNAL_VERSION}
}
function build_unity_image() {
    local is_gpu_image=$1
    if [ $is_gpu_image -eq 0 ]; then
        docker_tag=${ML_DEV_DOCKER_TAG}
    else
        docker_tag=${ML_NPS_DOCKER_TAG}
    fi
    local base_images=$(get_docker_image ${ML_THIRDPARTY_BUILD_DOCKER_URL} ${ML_THIRDPARTY_BUILD_DOCKER_NAME} ${ML_THIRDPARTY_BUILD_DOCKER_TAG})
    local output_images=$(get_docker_image ${DOCKER_URL} ${ML_UNITY_DOCKER_NAME} ${docker_tag})
    build_image_internal $base_images $output_images unity-7.3.1 ${EXTERNAL_VERSION}
}

function build_thirdparty_image() {
    local base_images=$(get_docker_image ${ML_OS_BUILD_DOCKER_URL} ${ML_OS_BUILD_DOCKER_NAME} ${ML_OS_BUILD_DOCKER_TAG})
    local output_images=$(get_docker_image ${ML_THIRDPARTY_BUILD_DOCKER_URL} ${ML_THIRDPARTY_BUILD_DOCKER_NAME} ${ML_THIRDPARTY_BUILD_DOCKER_TAG})
    build_image_internal $base_images $output_images thirdparty-7.3.1 ${EXTERNAL_VERSION}
}
function build_thirdparty_gpu_image() {
    local base_images=$(get_docker_image ${ML_OS_BUILD_DOCKER_URL} ${ML_GPU_OS_BUILD_DOCKER_NAME} ${ML_OS_BUILD_DOCKER_TAG})
    local output_images=$(get_docker_image ${ML_THIRDPARTY_GPU_BUILD_DOCKER_URL} ${ML_THIRDPARTY_GPU_BUILD_DOCKER_NAME} ${ML_THIRDPARTY_GPU_BUILD_DOCKER_TAG})
    build_image_internal $base_images $output_images thirdparty_gpu ${EXTERNAL_VERSION}
}
function build_thirdparty_newgcc_image() {
    local base_images=$(get_docker_image ${ML_OS_BUILD_DOCKER_URL} ${ML_NEWGCC_OS_BUILD_DOCKER_NAME} ${ML_NEWGCC_BUILD_DOCKER_TAG})
    local output_images=$(get_docker_image ${ML_THIRDPARTY_BUILD_DOCKER_URL} ${ML_THIRDPARTY_NEWGCC_BUILD_DOCKER_NAME} ${ML_THIRDPARTY_NEWGCC_BUILD_DOCKER_TAG})
    build_image_internal $base_images $output_images thirdparty-gcc20 ${EXTERNAL_VERSION}
}
function build_thirdparty_gcc_system_arch_image() {
    local base_images=$(get_docker_image ${ML_OS_BUILD_DOCKER_URL} ${ML_GCC_OS_BUILD_DOCKER_NAME} ${ML_NEWGCC_BUILD_DOCKER_TAG})
    local output_images=$(get_docker_image ${ML_THIRDPARTY_BUILD_DOCKER_URL} ${ML_THIRDPARTY_GCC_BUILD_DOCKER_NAME} ${ML_THIRDPARTY_NEWGCC_BUILD_DOCKER_TAG})
    build_image_internal $base_images $output_images thirdparty-xx ${EXTERNAL_VERSION}
}


function build_nps_image() {
    local base_images=$(get_docker_image ${ML_THIRDPARTY_GPU_BUILD_DOCKER_URL} ${ML_THIRDPARTY_GPU_BUILD_DOCKER_NAME} ${ML_THIRDPARTY_GPU_BUILD_DOCKER_TAG})
    local output_images=$(get_docker_image ${DOCKER_URL} ${ML_NPS_DOCKER_NAME} ${DOCKER_TAG})
    build_image_internal $base_images $output_images nps-7.3.1-gpu-gpu ${EXTERNAL_VERSION}
}
function build_image() {
    local is_dev_image=$1
    local is_unity_image=$2
    local is_gpu_image=$3
    local is_arm_image=$4
    if [[ $is_dev_image -eq 1 ]]; then
        if [[ $is_gpu_image -eq 1 ]]; then
            build_nps_image
            return
        fi
        if [[ $is_unity_image -eq 1 ]];then
            build_unity_image $is_gpu_image
        else
            build_dev_image
        fi
    else
        if [[ $is_gpu_image -eq 1 ]]; then
            build_thirdparty_gpu_image
        elif [[ $is_arm_image -eq 1 ]];then
            build_thirdparty_newgcc_image $*
        else
            build_thirdparty_image
        fi
    fi
}
function push_image() {
    local is_dev_image=$1
    local is_unity_image=$2
    local is_gpu_image=$3
    local is_arm_image=$4
    if [[ $is_dev_image -eq 1 ]]; then
        if [[ $is_gpu_image -eq 1 ]]; then
            image_name=$(get_docker_image ${DOCKER_URL} ${ML_NPS_DOCKER_NAME} ${DOCKER_TAG})
        else
            if [[ $is_unity_image -eq 1 ]];then
                image_name=$(get_docker_image ${DOCKER_URL} ${ML_UNITY_DOCKER_NAME} ${DOCKER_TAG})
            else
                image_name=$(get_docker_image ${DOCKER_URL} ${ML_DEV_DOCKER_NAME} ${DOCKER_TAG})
            fi
        fi
    else
        if [[ $is_gpu_image -eq 1 ]]; then
            image_name=$(get_docker_image ${ML_THIRDPARTY_GPU_BUILD_DOCKER_URL} ${ML_THIRDPARTY_GPU_BUILD_DOCKER_NAME} ${ML_THIRDPARTY_GPU_BUILD_DOCKER_TAG})
        elif [[ $is_arm_image -eq 1 ]];then
            image_name=$(get_docker_image ${ML_THIRDPARTY_BUILD_DOCKER_URL} ${ML_THIRDPARTY_NEWGCC_BUILD_DOCKER_NAME} ${ML_THIRDPARTY_NEWGCC_BUILD_DOCKER_TAG})
        else
            image_name=$(get_docker_image ${ML_THIRDPARTY_BUILD_DOCKER_URL} ${ML_THIRDPARTY_BUILD_DOCKER_NAME} ${ML_THIRDPARTY_BUILD_DOCKER_TAG})
        fi
    fi
    docker push $image_name
}
function help_usage() {
	echo "sh create_image.sh -b[uild] -p[ush]"
}
function Main() {
   local is_dev_image=1
   local is_unity_image=0
   local is_cuda_image=0
   local is_arm_image=0
   while getopts hbptdvmcu OPTION
    do
       case ${OPTION} in
            h) help_usage
            exit 1
            ;;
            c) is_cuda_image=1
            ;;
            d) is_dev_image=0
            ;;
            t) is_dev_image=0
            ;;
            u) is_unity_image=1
            ;;
            m) is_arm_image=1
            ;;
            b) build_image $is_dev_image $is_unity_image $is_cuda_image $is_arm_image
            ;;
            p) push_image $is_dev_image $is_unity_image $is_cuda_image $is_arm_image
            ;;
        esac
   done
}
Main $*
