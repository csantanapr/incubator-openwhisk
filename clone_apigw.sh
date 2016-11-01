#!/bin/bash

mkdir core/apigw
pushd core/apigw
git clone git@github.ibm.com:apimesh/gateway-service-gw-controller.git
git clone git@github.ibm.com:apimesh/apigateway.git
git clone git@github.ibm.com:apimesh/gateway-service-redis.git
git clone git@github.ibm.com:apimesh/gateway-service-manager.git
git clone git@github.ibm.com:apimesh/gateway-director-management-interface.git
popd


