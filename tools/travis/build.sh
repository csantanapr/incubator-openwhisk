#!/bin/bash
set -eux

# Build script for Travis-CI.

SCRIPTDIR=$(cd $(dirname "$0") && pwd)
ROOTDIR="$SCRIPTDIR/../.."

cd $ROOTDIR
time tools/build/scanCode.py .

cd $ROOTDIR/ansible

ANSIBLE_CMD="ansible-playbook -i environments/local -e docker_image_prefix=testing"

time $ANSIBLE_CMD setup.yml
time $ANSIBLE_CMD prereq.yml
time $ANSIBLE_CMD couchdb.yml
time $ANSIBLE_CMD initdb.yml
time $ANSIBLE_CMD apigateway.yml

cd $ROOTDIR

time ./gradlew distDocker -PdockerImagePrefix=testing

cd $ROOTDIR/ansible

time $ANSIBLE_CMD wipe.yml

time docker commit couchdb "csantanapr/couchdb"

time $ANSIBLE_CMD openwhisk.yml

cd $ROOTDIR
cat whisk.properties
time ./gradlew :tests:testLean

cd $ROOTDIR/ansible
time $ANSIBLE_CMD logs.yml

cd $ROOTDIR
time tools/build/checkLogs.py logs
