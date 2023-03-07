#!/bin/bash

set -e
set -x

export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")

source ${BASEDIR}/docker/VERSIONS
function build_on_docker() {
    DOCKER_URL=$1
    DOCKER_NAME=$2
    DOCKER_TAG=$3

    DOCKER_IMAGE_OUTPUT=$(docker images --filter=reference=${DOCKER_URL}/${DOCKER_NAME}:${DOCKER_TAG})
    IMAGE_LINE=`echo "$DOCKER_IMAGE_OUTPUT" | sed -n '2p'`
    if [[ -z $IMAGE_LINE ]]; then
        # start pulling image
        echo "pulling docker image ${DOCKER_URL}/${DOCKER_NAME}:${DOCKER_TAG}"
        docker pull ${DOCKER_URL}/${DOCKER_NAME}:${DOCKER_TAG}
    fi

    set +e
    docker ps -a | grep ${DOCKER_NAME}-${DOCKER_TAG}
    if [ ! $? -eq 0 ]; then
        set -e
        docker run -dt --net=host --name ${DOCKER_NAME}-${DOCKER_TAG} \
                --cap-add=SYS_PTRACE --cap-add=SYS_NICE \
                --security-opt seccomp=unconfined \
                -e TERM=xterm-256color  \
                -v $BASEDIR:$BASEDIR -v $HOME:$HOME \
                -v /home:/home -v /data:/data \
                -v /mnt:/mnt -v /data/code/ml-platform-thirdparty \
                -v /mnt/disk0:/mnt/disk0 ${DOCKER_URL}/${DOCKER_NAME}:${DOCKER_TAG}
    fi
    set -e
    shift 3
    docker start ${DOCKER_NAME}-${DOCKER_TAG}
    docker exec -i -w $BASEDIR ${DOCKER_NAME}-${DOCKER_TAG} /bin/bash -c "source ~/.bashrc && ${BASEDIR}/compile.sh $*"
}
function build_thirdparty_images() {
    build_on_docker $ML_OS_BUILD_DOCKER_URL \
                    $ML_OS_BUILD_DOCKER_NAME \
                    $ML_OS_BUILD_DOCKER_TAG \
                    -n thirdparty \
                    -o \
                    $*
}
function build_dev_images() {
    build_on_docker $ML_THIRDPARTY_BUILD_DOCKER_URL \
                    $ML_THIRDPARTY_BUILD_DOCKER_NAME \
                    $ML_THIRDPARTY_BUILD_DOCKER_TAG \
                    -n dev \
                    $*
}
function build_unity_newgcc_images() {
    build_on_docker $ML_THIRDPARTY_BUILD_DOCKER_URL \
                    $ML_THIRDPARTY_NEWGCC_BUILD_DOCKER_NAME \
                    $ML_THIRDPARTY_NEWGCC_BUILD_DOCKER_TAG \
                    -n unity-gcc20 \
                    -u \
                    -m \
                    $*
}
function build_unity_gcc_system_arch_images() {
    build_on_docker $ML_THIRDPARTY_BUILD_DOCKER_URL        \
                    $ML_THIRDPARTY_GCC_BUILD_DOCKER_NAME   \
                    $ML_THIRDPARTY_NEWGCC_BUILD_DOCKER_TAG \
                    -n unity                               \
                    -u \
                    $*
}

function build_unity_images() {
    build_on_docker $ML_THIRDPARTY_BUILD_DOCKER_URL \
                    $ML_THIRDPARTY_BUILD_DOCKER_NAME \
                    $ML_THIRDPARTY_BUILD_DOCKER_TAG \
                    -n unity \
                    -u \
                    $*
}
function build_thirdparty_gpu_images() {
    build_on_docker $ML_OS_BUILD_DOCKER_URL      \
                    $ML_GPU_OS_BUILD_DOCKER_NAME \
                    $ML_OS_BUILD_DOCKER_TAG      \
                    -n thirdparty_gpu            \
                    -o \
                    -g \
                    $*
}
function build_thirdparty_arm_images() {
    build_on_docker $ML_OS_BUILD_DOCKER_URL      \
                    $ML_AWS_OS_BUILD_DOCKER_NAME \
                    $ML_OS_BUILD_DOCKER_TAG      \
                    -n thirdparty_arm            \
                    -o \
                    -m \
                    $*
}
function build_thirdparty_newgcc_images() {
    build_on_docker $ML_OS_BUILD_DOCKER_URL      \
                    $ML_NEWGCC_OS_BUILD_DOCKER_NAME \
                    $ML_NEWGCC_BUILD_DOCKER_TAG  \
                    -n thirdparty-gcc20          \
                    -o \
                    -m \
                    $*
}
function build_thirdparty_gcc_system_arch_images() {
    build_on_docker $ML_OS_BUILD_DOCKER_URL      \
                    $ML_GCC_OS_BUILD_DOCKER_NAME \
                    $ML_NEWGCC_BUILD_DOCKER_TAG  \
                    -n thirdparty                \
                    -o \
                    $*
}



function build_nps_images() {
    build_on_docker $ML_THIRDPARTY_GPU_BUILD_DOCKER_URL \
                    $ML_THIRDPARTY_GPU_BUILD_DOCKER_NAME \
                    $ML_THIRDPARTY_GPU_BUILD_DOCKER_TAG \
                    -n nps \
                    -g \
                    $*
}
function build() {
    local is_dev_image=$1
    local is_unity_image=$2
    local is_cuda_image=$3
    local is_arm_image=$4
    shift 4
    if [[ $is_dev_image -eq 1 ]]; then
        if [[ $is_cuda_image -eq 1 ]];then
            build_nps_images $*
            return
        fi
        if [[ $is_arm_image -eq 1 ]];then
            build_unity_newgcc_images $*
            return
        fi
        if [[ $is_unity_image -eq 1 ]];then
            build_unity_images $*
        else
            build_dev_images $*
        fi
    else
        if [[ $is_cuda_image -eq 1 ]];then
            build_thirdparty_gpu_images $*
        elif [[ $is_arm_image -eq 1 ]];then
            build_thirdparty_newgcc_images $*
        else 
            build_thirdparty_images $*
        fi
    fi
}

function help_usage() {
	echo "create_library -e -b -p -u";
}
function Main() {
   local is_dev_image=1
   local is_unity_image=0
   local is_cuda_image=0
   local is_arm_image=0
   while getopts guhemptv OPTION
    do
       case ${OPTION} in
            h) help_usage
            exit 1
            ;;
            e) is_dev_image=0
            ;;
            u) is_unity_image=1
            ;;
            g) is_cuda_image=1
            ;;
            m) is_arm_image=1
            ;;
        esac
   done
   build $is_dev_image $is_unity_image $is_cuda_image $is_arm_image $*
}
Main $*
