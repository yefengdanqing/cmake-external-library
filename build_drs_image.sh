#!/bin/bash

set -x
set -e

source docker/VERSIONS

function build_compile_image(){
    local if_push=$1
    docker_tag=${DRS_BUILD_DOCKER_URL}/${DRS_BUILD_DOCKER_NAME}:${DRS_BUILD_DOCKER_TAG}
    docker build -f docker/Dockerfile_build_drs -t ${docker_tag} \
	        --build-arg GO_VERSION=${GO_VERSION} . --no-cache
    if [ $if_push -eq 1 ];
    then
        docker push ${docker_tag}
    fi
}

function build_release_image(){
    echo "pass"    
}

Main(){
    local push_image=0 
    while getopts "ph" opt
    do
        case "$opt" in
            p)
            push_image=1
            ;;
            h)
            echo "-p | push image"
            ;;
        esac
    done
    build_compile_image $push_image
}

Main $*
echo $?
