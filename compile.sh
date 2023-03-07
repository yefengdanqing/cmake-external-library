#!/bin/bash

#set -e
set -x

export LANG=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")
source ${BASEDIR}/docker/VERSIONS
cd $BASEDIR

function p_help() {
    echo "usage : sh compile.sh to build external libraries"
    echo "ex [ -h used to show help]"
    echo "ex [ -a used to build with asan]"
    echo "ex [ -d used to build debug mode]"
    echo "ex [ -v used to specify revision of external]"
    echo "ex [ -p used for package only]"
    echo "ex [ -b used for build only]"
    echo "ex [ -f used to force build all]"
    echo "ex [ -o only build 3rdparty ]"
    echo "ex [ -u only build unity ]"
    echo "ex [ -g compile torch libraries ]"
    echo "ex [ -m compile to arm]"
    echo "ex [ -n build name]"
}

function rebuild_library() {
    deps_dir=$1
    lib_name="mkl faiss libtorch xgboost cuda pai-blade" # cpu thirdparty is different of gpu
    for i in $lib_name
    do
        if [ -d "$deps_dir/$i" ];then
            rm -rf "$deps_dir/$i"
        fi
    done
}

Main()
{
    local l_base_dir=$PWD
    local build_type=RelWithDebInfo
    local build_dir=${SYSTEM_ARCH}/build
    local CURR_TAG_VERSION=master
    local build_only=0
    local package_only=0
    local force_all=0
    local build_only_thirdparty="OFF"
    local build_unity_library="OFF"
    local build_gpu_library="OFF" 
    local use_dev_libtorch="OFF" 
    local dev_libtorch_version="1.12.1"
    local build_name="thirdparty"
    local deps_dir="${BASEDIR}/${SYSTEM_ARCH}/built"
    local build_cxx_standard=17
    while getopts v:n:x:t:abgzdfhmpotu OPTION
    do
       case ${OPTION} in
            h) p_help
            exit 0
            ;;
            v) CURR_TAG_VERSION=${OPTARG}
            ;;
            n) build_name=${OPTARG}
               build_name=${build_name}-${GCC_VERSION}
            ;;
            a) build_type=Asan
            ;;
            d) build_type=Debug
            ;;
            b) build_only=1
            ;;
            p) package_only=1
            ;;
            f) force_all=1
            ;;
            o) build_only_thirdparty="ON"
            ;;
            u) build_unity_library="ON" 
            ;;
            g) build_gpu_library="ON" 
               build_name=${build_name}-gpu
            ;;
            z) build_gpu_library="ON"
            ;;
            x) build_dir=${OPTARG}
            ;;
            m) build_cxx_standard=20
            ;;
            t) dev_libtorch_version=${OPTARG}
               use_dev_libtorch="ON"
            ;;
        esac  
    done
    build_dir=${build_dir}-${build_name}
    if [ "${build_type}" = "Asan" ]; then
        build_dir=${build_dir}-asan
    elif [ "${build_type}" = "Debug" ]; then
        build_dir=${build_dir}-debug
    fi
    if [[ $build_only_thirdparty == "OFF" ]]; then
        deps_dir=/data/code/ml-platform-thirdparty
    else
        deps_dir=${deps_dir}-${build_name}
    fi
    if [ ! ${package_only} -eq 1 ]; then
        #export GIT_SSH_COMMAND="ssh -vvv"
        git fetch
        git checkout ${CURR_TAG_VERSION}
        rm -rf ${build_dir}
        mkdir -p ${build_dir}
        if [ ${force_all} -eq 1 ]; then
            rm -rf $deps_dir && mkdir $deps_dir
        fi
        cd ${build_dir}
        #rebuild_library $deps_dir
        cmake3 ../../ -DDEPS_DIR=${deps_dir}                 \
            -DCMAKE_BUILD_TYPE=${build_type}                 \
            -DBUILD_ONLY_THIRDPARTY=${build_only_thirdparty} \
            -DBUILD_UNITY_LIBRARY=${build_unity_library}     \
            -DUSE_TORCH_CUDA=${build_gpu_library}            \
            -DUSE_DEV_LIBTORCH=${use_dev_libtorch}           \
            -DDEV_LIBTORCH_VERSION=${dev_libtorch_version}   \
            -DCMAKE_CXX_STANDARD=${build_cxx_standard}
        ${BASEDIR}/scripts/update-path-refs.py -s ${deps_dir} -b ${deps_dir}
    fi

    if [ ! ${build_only} -eq 1 ];then
        cd ${BASEDIR}
        rev=$ML_DEV_DOCKER_TAG
        RELEASE=${BASEDIR}/${SYSTEM_ARCH}
        if [ ! -d $RELEASE ] ; then
            mkdir -p $RELEASE
        fi
        filename=${RELEASE}/ml-platform-${build_name}-${build_type}-${rev}.tar.bz2
        if [ -f $filename ]; then
            rm -rf $filename
        fi
        tar --use-compress-program=pbzip2 -cf $filename -C ${deps_dir} .
        which pip
        if [[ $? -eq 0 ]];then
          pip install awscli-plugin-endpoint
        else
          pip3 install awscli-plugin-endpoint
        fi
        aws s3 cp $filename ${EXTERNAL_URL}/
    fi
}

Main "$@"
exit $?
