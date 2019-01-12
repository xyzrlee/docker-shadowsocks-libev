#!/usr/bin/env bash

echo "$DOCKER_PASSWORD" | docker login -u xyzrlee --password-stdin
docker-compose push
docker logout
