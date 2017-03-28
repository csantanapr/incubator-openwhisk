#!/bin/bash
set -eu

docker_image_prefix="testing"
dockerhub_image_prefix="openwhisk"
docker login -u "${DOCKER_USER}" -p "${DOCKER_PASS}"

#capture couchdb setup
docker commit couchdb "${docker_image_prefix}/couchdb"

#deploy specific openwhisk core images
for container in "controller"     \
                 "invoker"        \
                 "couchdb"        \
                 "dockerskeleton" \
                 "nodejs6action"  \
                 "python2action"  \
                 "python3action"  \
                 "swift3action"   \
                 "java8action"
do
  docker tag "${docker_image_prefix}/${container}" "${dockerhub_image_prefix}/${container}:latest"
  docker tag "${docker_image_prefix}/${container}" "${dockerhub_image_prefix}/${container}:${TRAVIS_BRANCH}-${TRAVIS_COMMIT::7}"
  docker push "${dockerhub_image_prefix}/${container}"
done
