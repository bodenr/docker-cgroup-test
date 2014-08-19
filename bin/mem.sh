#!/bin/bash

source ./common.include
TEST_NAME="mem"

assert_docker

# build the docker image
build_image $TEST_NAME

do_stop() {
    popd
    log "Stopping container $CID..."
    docker stop "$CID"
}

do_exit() {
    do_stop
    log "Removing docker image $IMAGE_NAME..."
    docker rmi "$TEST_NAME"
	exit
}

log "Starting image with 500MB memory limit and no swap limit..."
CID=$(docker run -d -lxc-conf="lxc.cgroup.memory.limit_in_bytes = 524300000" "$TEST_NAME")
trap do_stop SIGINT
pushd /sys/fs/cgroup/memory/lxc/"$CID"*
log "Press CRTL+c to exit"
mem_watch
do_stop

log "Starting image with 500MB memory limit and 200MB swap limit..."
CID=$(docker run -d -lxc-conf="lxc.cgroup.memory.limit_in_bytes = 524300000" -lxc-conf="lxc.cgroup.memory.memsw.limit_in_bytes = 734000000" "$TEST_NAME")
log "Started $CID"
trap do_exit SIGINT
pushd /sys/fs/cgroup/memory/lxc/"$CID"*
log "Press CRTL+c to exit"
mem_watch
do_exit




