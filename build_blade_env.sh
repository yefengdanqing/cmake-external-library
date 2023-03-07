#!/bin/bash
set -x
push_images=0
build_images=1
function build_docker_image() {
    local dockerfile=$1
    local output_images=$2
    local base_nvidia_image=$3
    local torch_version=$4
    local torchvision_version=$5
    local torch_addons=$6
    local pai_build_gpu="$7"
    local blade_repo_url=$8
    docker build -f ${dockerfile} -t ${output_images} \
    --build-arg nvidia_base=${base_nvidia_image}      \
    --build-arg torch=${torch_version}                \
    --build-arg torchvision=${torchvision_version}    \
    --build-arg torch_addons="${torch_addons}"        \
    --build-arg pai_build_gpu="${pai_build_gpu}"      \
    --build-arg blade_repo_url="$blade_repo_url"      \
    .
}
function push_docker_image() {
    if [ $push_images -eq 1 ]; then
       docker push $output_images
    fi
}

main() {
    local url="hub.mobvista.com/ml-platform/pytorch-blade"
    local tag="1.4"
    local image_internal="${url}:${tag}"
    local nvidia_base="nvidia/cuda:11.0.3-devel-centos7"
    local docker_file="docker/Dockerfile_blade"
    local torch_version="1.7.1+cu110"
    local torchvision_version="0.8.2+cu110"
    local torch_addons="3.18.1+1.7.1.cu110"
    local pai_build_gpu="3.18.1+cu110.2.4.0.1.7.1"
    local blade_repo_url="https://pai-blade.oss-cn-zhangjiakou.aliyuncs.com/release/repo_ext.html"
    local blade_repo_url="https://pai-blade.oss-cn-zhangjiakou.aliyuncs.com/release/repo_ext.html"
    docker pull $image_internal
    if [ $? -ne 0 ];then
        build_docker_image $docker_file $image_internal $nvidia_base \
                           ${torch_version} ${torchvision_version}   \
                           ${torch_addons} ${pai_build_gpu}          \
                           ${blade_repo_url}
    fi
    push_docker_image
}
main $*
exit $?
