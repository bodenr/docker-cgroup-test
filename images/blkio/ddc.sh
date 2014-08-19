#!/bin/bash

if [ -z "$COUNT" ] ; then
    COUNT=100
fi

echo "dd with ${COUNT} 1M blocks"

if [ -z "$SYNCIO" ] ; then
    echo "Using async I/O"
else
    echo "Using sync I/O"
fi

if [ ! -z "$SYNCIO" ] ; then
    if [ ! -z "$READ" ] ; then
        echo "dd from volume to container fs..."
        time dd if=/tmpfs/data of=/tmp/out iflag=dsync oflag=dsync bs=1M count="$COUNT"
    else
        echo "dd from container fs to volume..."
        time dd if=/dev/zero of=/tmpfs/out iflag=dsync oflag=dsync bs=1M count="$COUNT"
    fi
else
    if [ ! -z "$READ" ] ; then
        echo "dd from volume to container fs..."
        time dd if=/tmpfs/data of=/tmp/out bs=1M count="$COUNT"
    else
        echo "dd from container fs to volume..."
        time dd if=/dev/zero of=/tmpfs/out bs=1M count="$COUNT"
    fi
fi
rm -f /tmp/out
rm -f /tmpfs/out


