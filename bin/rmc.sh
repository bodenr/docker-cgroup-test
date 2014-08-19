#!/bin/bash

docker ps -a -q | xargs docker stop
docker ps -a -q | xargs -L1 docker rm

