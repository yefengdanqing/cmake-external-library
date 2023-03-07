#!/bin/bash


set -x

export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")

source ${BASEDIR}/docker/VERSIONS

function build_base_images() {
    base_image=$1
    output_image_name=$2
    output_image_tag=$3
    gcc_toolset=$4
    docker_file=$5
    img_url=${ML_OS_BUILD_DOCKER_URL}/${output_image_name}:${output_image_tag}
    if [[ "$base_image" == *"centos:8"* ]];then
      is_centos8="true"
    else
      is_centos8="false"
    fi
    #docker build --no-cache -f $docker_file            \
    docker build -f $docker_file                        \
        --build-arg base_centos_image_tag=${base_image} \
        --build-arg gcc_toolset=${gcc_toolset}          \
        --build-arg is_centos8="${is_centos8}"          \
        -t $img_url .
}


function build_blade_image() {
    base_image=${ML_GPU_CENTOS_VERSION}
    output_image_name=${ML_GPU_OS_BUILD_DOCKER_NAME}
    echo $base_image | grep -i nvidia
    if [[ $? -eq 0 ]]; then
        echo "build nvidia/cuda image"
        build_base_images $base_image $output_image_name ${ML_OS_BUILD_DOCKER_TAG} "gcc_toolset-7" docker/Dockerfile_centos_build
    fi
}

function  build_centos_image() {
    base_image=${ML_CENTOS_VERSION}
    output_image_name=${ML_OS_BUILD_DOCKER_NAME}
    build_base_images $base_image $output_image_name ${ML_OS_BUILD_DOCKER_TAG} "gcc_toolset-7" docker/Dockerfile_centos_build
}
function  build_aws_image() {
    base_image=${ML_AWS_VERSION}
    output_image_name=${ML_AWS_OS_BUILD_DOCKER_NAME}
    echo "build aws $output_image_name"
    build_base_images $base_image $output_image_name ${ML_NEWGCC_BUILD_DOCKER_TAG} "gcc_toolset-7" docker/Dockerfile_aws_build
}
function  build_newgcc_image() {
    base_image=${ML_NEWGCC_VERSION}
    output_image_name=${ML_NEWGCC_OS_BUILD_DOCKER_NAME}
    echo "build newgcc $output_image_name"
    build_base_images $base_image $output_image_name ${ML_NEWGCC_BUILD_DOCKER_TAG} "gcc_toolset-7" docker/Dockerfile_newgcc_build
}

function  build_gcc10_on_centos7_image_internal() {
    local base_image=$1
    local arch=$2
    local gcc_toolset=$3
    echo $base_image |grep cuda
    if [ $? -eq 0 ]; then
        local os=$(echo $base_image | awk -F'[-]' '{printf("%s", $NF)}')
    else
        local os=$(echo $base_image | awk -F'[:/.]' '{printf("%s%s", $(NF-3), $(NF-2))}')
    fi
    output_image_name=$(printf $ML_GCC_OS_BUILD_DOCKER_NAME $os-$arch)
    echo "build newgcc $output_image_name"
    docker_file=docker/Dockerfile_gcc_on_centos_build
    build_base_images $base_image $output_image_name \
                      ${ML_GCC_OS_BUILD_DOCKER_TAG}  \
                      $gcc_toolset                   \
                      $docker_file
}

function  build_x86_gcc10_on_centos7_image() {
    base_image=${ML_GCC_X86_CENTOS_VERSION}
    build_gcc10_on_centos7_image_internal $base_image base "devtoolset-10" "false"
}

main(){
    while getopts "aghnx:t" opt
    do
        case "$opt" in
            a)
                build_aws_image
                exit
                ;;

            g)
                build_blade_image
                echo "build_blade_image"
                exit
                ;;
            n)
                build_newgcc_image
                echo "build_newgcc_image"
                exit
                ;;
            t)
                build_x86_gcc10_on_centos7_image
                echo "build_x86_gcc10_on_centos7_image"
                exit
                ;;
            x)  arch=${OPTARG}
                ;;
            h)
                echo "-g | build blade-gpu base image"
                echo "-a | build aws base image"
                echo "-x | build arm|x86"
                exit
                ;;
        esac
    done
    if [ -z $arch ]; then
        build_centos_image
        echo "build_centos_image"
    else
        if [ $arch == "aarch64" ]; then
            base_image=${ML_GCC_ARM_CENTOS_VERSION}
            arch="$arch-cpu-base"
            gcc_toolset="devtoolset-10"
        elif [[ $arch == "x86_64" ]];then
            base_image=${ML_GCC_X86_CENTOS_VERSION}
            arch="x86_64-cpu-base"
            gcc_toolset="devtoolset-10"
        elif [[ $arch == "x86_64-gpu" ]];then
            base_image=${ML_GCC_X86GPU_CENTOS_VERSION}
            arch="x86_64-gpu-base"
            gcc_toolset="devtoolset-7"
        fi
        if [ -z $base_image ]; then
            echo "$arch not in list"
            exit
        fi
        build_gcc10_on_centos7_image_internal $base_image $arch $gcc_toolset
    fi
}
main $*
