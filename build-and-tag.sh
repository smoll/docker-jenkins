#!/bin/bash

build_and_tag() {
    local namespace=$1
    local image_name=$2
    local dir=$3

    echo "#####"
    echo "# Building $namespace/$image_name from directory: $dir"
    echo "#####"

    docker build -t $namespace/$image_name:latest $dir

    local id="$(docker images | grep '$namespace/$image_name' | head -n 1 | awk '{print $3}')"
    docker tag "$id" $namespace/$image_name:master
    docker tag "$id" $namespace/$image_name:latest
}

#
# Build and tag each image, sequentially
#
build_and_tag smoll jenkins master
build_and_tag smoll jenkins-data data
build_and_tag smoll jenkins-nginx nginx
