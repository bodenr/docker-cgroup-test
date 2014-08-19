#!/bin/bash

source ./common.include
TEST_NAME="blkio"
TMPFS=/tmp/tmpfs
LOSETUP=/dev/loop0
MM="7:0" # loop devices are 7:x
MNT=/mnt/tmpfs

assert_docker

# build the docker image
build_image $TEST_NAME

do_stop() {
    popd
    log "Stopping container $CID..."
    docker stop "$CID"
    log "Echoing container logs..."
    log "-------------------------"
    docker logs "$CID"
    log "-------------------------"
}

do_exit() {
    do_stop
    log "Removing docker image $IMAGE_NAME..."
    docker rmi "$TEST_NAME" > /dev/null
    log "Removing losetup mounts..."
    umount "$MNT" > /dev/null
    losetup -d "$LOSETUP" > /dev/null
    rm -rf "$TMPFS"
    rm -rf "$MNT"
    exit
}

setup_mnt() {
    log "Setting up tmp mount..."
    assert_losetup $LOSETUP > /dev/null
    dd if=/dev/zero of="$TMPFS" bs=1M count=1000 > /dev/null
    losetup "$LOSETUP" "$TMPFS" > /dev/null
    mkfs -t ext4 -m 1 -v "$LOSETUP" > /dev/null
    mkdir -p "$MNT"
    mount -t ext4 "$LOSETUP" "$MNT" > /dev/null
    dd if=/dev/zero of="$MNT"/data bs=1M count=500 > /dev/null
}

setup_mnt

# Synchronous I/O tests
echo 3 > /proc/sys/vm/drop_caches
log "Starting SYNC READ TEST. 8MB read/write bps cap for I/O test..."
CID=$(docker run -e="SYNCIO=1" -e="COUNT=50" -e="READ=1" -d -v=$MNT:/tmpfs:rw -lxc-conf="lxc.cgroup.blkio.throttle.write_bps_device = $MM 8389000" -lxc-conf="lxc.cgroup.blkio.throttle.read_bps_device = $MM 8389000" "$TEST_NAME")
trap do_stop SIGINT
pushd /sys/fs/cgroup/memory/lxc/"$CID"*
log "Press CRTL+c to exit"
mem_watch
do_stop

echo 3 > /proc/sys/vm/drop_caches
log "Starting SYNC WRITE TEST. 8MB read/write bps cap for I/O test..."
CID=$(docker run -e="SYNCIO=1" -e="COUNT=50" -d -v=$MNT:/tmpfs:rw -lxc-conf="lxc.cgroup.blkio.throttle.write_bps_device = $MM 8389000" -lxc-conf="lxc.cgroup.blkio.throttle.read_bps_device = $MM 8389000" "$TEST_NAME")
trap do_stop SIGINT
pushd /sys/fs/cgroup/memory/lxc/"$CID"*
log "Press CRTL+c to exit"
mem_watch
do_stop

echo 3 > /proc/sys/vm/drop_caches
log "Starting SYNC READ TEST. No read/write bps cap for sync I/O test..."
CID=$(docker run -e="SYNCIO=1" -e="COUNT=50" -e="READ=1" -d -v=$MNT:/tmpfs:rw "$TEST_NAME")
trap do_stop SIGINT
pushd /sys/fs/cgroup/memory/lxc/"$CID"*
log "Press CRTL+c to exit"
mem_watch
do_stop

echo 3 > /proc/sys/vm/drop_caches
log "Starting SYNC WRITE TEST. No read/write bps cap for sync I/O test..."
CID=$(docker run -e="SYNCIO=1" -e="COUNT=50" -d -v=$MNT:/tmpfs:rw "$TEST_NAME")
trap do_stop SIGINT
pushd /sys/fs/cgroup/memory/lxc/"$CID"*
log "Press CRTL+c to exit"
mem_watch
do_stop


# Async I/O tests
echo 3 > /proc/sys/vm/drop_caches
log "Starting ASYNC READ TEST. 8MB read/write bps cap for async I/O test..."
CID=$(docker run -e="COUNT=50" -e="READ=1" -d -v=$MNT:/tmpfs:rw -lxc-conf="lxc.cgroup.blkio.throttle.write_bps_device = $MM 8389000" -lxc-conf="lxc.cgroup.blkio.throttle.read_bps_device = $MM 8389000" "$TEST_NAME")
trap do_stop SIGINT
pushd /sys/fs/cgroup/memory/lxc/"$CID"*
log "Press CRTL+c to exit"
mem_watch
do_stop

echo 3 > /proc/sys/vm/drop_caches
log "Starting ASYNC WRITE TEST. 8MB read/write bps cap for async I/O test..."
CID=$(docker run -e="COUNT=50" -d -v=$MNT:/tmpfs:rw -lxc-conf="lxc.cgroup.blkio.throttle.write_bps_device = $MM 8389000" -lxc-conf="lxc.cgroup.blkio.throttle.read_bps_device = $MM 8389000" "$TEST_NAME")
trap do_stop SIGINT
pushd /sys/fs/cgroup/memory/lxc/"$CID"*
log "Press CRTL+c to exit"
mem_watch
do_stop


echo 3 > /proc/sys/vm/drop_caches
log "Starting ASYNC READ TEST. No read/write bps cap for async I/O test..."
CID=$(docker run -e="COUNT=50" -e="READ=1" -d -v=$MNT:/tmpfs:rw "$TEST_NAME")
trap do_stop SIGINT
pushd /sys/fs/cgroup/memory/lxc/"$CID"*
log "Press CRTL+c to exit"
mem_watch
do_stop

echo 3 > /proc/sys/vm/drop_caches
log "Starting ASYNC WRITE TEST. No read/write bps cap for async I/O test..."
CID=$(docker run -e="COUNT=50" -d -v=$MNT:/tmpfs:rw "$TEST_NAME")
trap do_exit SIGINT
pushd /sys/fs/cgroup/memory/lxc/"$CID"*
log "Press CRTL+c to exit"
mem_watch
do_exit



