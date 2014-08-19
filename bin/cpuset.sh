#!/bin/bash


source ./common.include
TEST_NAME="cpuset"
CPU=0

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

log "Starting image not pinned..."
CID=$(docker run -d "$TEST_NAME")
log "Started $CID"
trap do_stop SIGINT
pushd /sys/fs/cgroup/cpuset/lxc/"$CID"*
log "Press CRTL+c to exit"
cpu_watch
do_stop


log "Starting image pinned to cpu ${CPU}..."
CID=$(docker run -d -lxc-conf="lxc.cgroup.cpuset.cpus = ${CPU}" "$TEST_NAME")
log "Started $CID"
trap do_exit SIGINT
pushd /sys/fs/cgroup/cpuset/lxc/"$CID"*
log "Press CRTL+c to exit"
cpu_watch
do_exit

