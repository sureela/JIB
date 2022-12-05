#!/bin/bash

set -o errexit
set -o xtrace

gcloud components install docker-credential-gcr

# Docker service does not run by default in Big Sur but can be started with the following commands.
if [ "${KOKORO_JOB_CLUSTER}" = "MACOS_EXTERNAL" ]; then
source github/jib/kokoro/docker_setup.sh
fi

# Try using docker host ip instead of localhost for http requests
echo "$(docker-machine ip default)"
export DOCKER_IP=$(hostname -i)
echo "$DOCKER_IP"

# From default hostname, get id of container to exclude
CONTAINER_ID=$(hostname)
echo "$CONTAINER_ID"

# Stops any left-over containers.
docker stop $(docker ps --all --quiet | grep -v "$CONTAINER_ID") || true
docker kill $(docker ps --all --quiet | grep -v "$CONTAINER_ID") || true

cd github/jib

# we only run integration tests on jib-core for presubmit
./gradlew clean build :jib-core:integrationTest --info --stacktrace
