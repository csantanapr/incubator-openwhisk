#!/bin/bash
set -eu

docker_image_prefix="testing"
dockerhub_image_prefix="csantanapr"
docker login -u "${DOCKER_USER}" -p "${DOCKER_PASS}"

#capture couchdb setup
#container="couchdb"
#docker commit couchdb "${dockerhub_image_prefix}/couchdb"
#docker tag "${docker_image_prefix}/${container}" "${dockerhub_image_prefix}/${container}:latest"
#  docker tag "${docker_image_prefix}/${container}" "${dockerhub_image_prefix}/${container}:${TRAVIS_BRANCH}-${TRAVIS_COMMIT::7}"
docker push "${dockerhub_image_prefix}/couchdb"

#deploy specific openwhisk core images
#for container in "controller"     \
#                 "invoker"        \
#                 "couchdb"        \
#                 "dockerskeleton" \
#                 "nodejs6action"  \
#                 "python2action"  \
#                 "python3action"  \
#                 "swift3action"   \
#                 "java8action"
#do
#  docker tag "${docker_image_prefix}/${container}" "${dockerhub_image_prefix}/${container}:latest"
#  docker tag "${docker_image_prefix}/${container}" "${dockerhub_image_prefix}/${container}:${TRAVIS_BRANCH}-${TRAVIS_COMMIT::7}"
#  docker push "${dockerhub_image_prefix}/${container}"
#done


time ./gradlew distDocker -PdockerImagePrefix=${dockerhub_image_prefix} -PdockerRegistry=docker.io -x tests:dat:blackbox:badproxy:distDocker -x tests:dat:blackbox:badaction:distDocker -x sdk:docker:distDocker -x tools:cli:distDocker -x core:nodejsActionBase:distDocker

