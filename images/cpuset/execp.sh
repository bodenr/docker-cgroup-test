#!/bin/bash

echo "execing child processes"
for i in `seq 1 5`;
do
	/execp
done

while true; do
	sleep 1
done
