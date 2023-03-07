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
function build_on_docker() {
    DOCKER_URL=$1
    DOCKER_NAME=$2
    DOCKER_TAG=$3

    DOCKER_IMAGE_OUTPUT=$(docker images --filter=reference=${DOCKER_URL}/${DOCKER_NAME}:${DOCKER_TAG})
    IMAGE_LINE=$(echo "$DOCKER_IMAGE_OUTPUT" | sed -n '2p')
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

function get_docker_image() {
    local docker_url=$1
    local docker_name=$2
    local docker_tag=$3
    printf "%s/%s:%s" $docker_url $docker_name $docker_tag
}
function build_and_push_image() {
    local  is_3rdparty_image=0
    local  is_unity_image=0
    local  is_gpu_image=0
    local  build_op=0
    local  push_op=0
    local  version="master"
    local  dev_libtorch_version=""
    while getopts a:bc:d:go:ptuv:hs: OPTION
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
            g) is_gpu_image=1
                ;;
            o) os_system=${OPTARG}
                ;;
            p) push_op=1
                ;;
            t) is_3rdparty_image=1
                ;;
            u) is_unity_image=1
                ;;
            v) version=$OPTARG
                ;;
            s) cpp_cmake_standard=$OPTARG
                ;;
            d) dev_libtorch_version=$OPTARG
                ;;
        esac
   done
   if [ -z $arch ] || [ -z $gcc_version ]; then
       echo "arch or gcc_version is null"
       exit
   fi
   # enable build-thirdparty-only and c++20
   ext_args=""
   system_arch=$(echo ${os_system}-$arch)
   if [ $is_3rdparty_image -eq 1 ]; then
       docker_name=$(printf $ML_GCC_OS_BUILD_DOCKER_NAME $system_arch-cpu-base)
       docker_tags="$ML_GCC_OS_BUILD_DOCKER_TAG"
       build_name="3rdparty-cpu"
       ext_args="-o "
   elif [[ $is_unity_image -eq 1 ]];then
       docker_name=$(printf $ML_THIRDPARTY_GCC_BUILD_DOCKER_NAME)
       docker_tags=$(printf $ML_THIRDPARTY_GCC_BUILD_DOCKER_TAG $system_arch-gcc$gcc_version-cpu)
       build_name="unity-cpu"
       ext_args="-u "
   fi
   if [ $cpp_cmake_standard -gt 17 ]; then
       ext_args="${ext_args}-m "
   fi
   if [ $is_gpu_image -eq 1 ]; then
       docker_name=$(echo ${docker_name} | sed 's/cpu/gpu/g')
       docker_tags=$(echo ${docker_tags} | sed 's/cpu/gpu/g')
       build_name=$(echo ${build_name} | sed 's/cpu/gpu/g')
       ext_args="${ext_args} -z "
   fi
   if [[ ! -z $dev_libtorch_version ]];then
       ext_args="${ext_args} -t $dev_libtorch_version"
   fi
   if [ $build_op -eq 1 ]; then
       build_on_docker ${ML_OS_BUILD_DOCKER_URL} $docker_name $docker_tags -b -n $build_name -v $version $ext_args
   fi
   if [ $push_op -eq 1 ]; then
       build_on_docker ${ML_OS_BUILD_DOCKER_URL} $docker_name $docker_tags -p -n $build_name -v $version $ext_args
   fi
}
build_and_push_image $*
