# Dockerfile for swift actions, overrides and extends ActionRunner from actionProxy
# This Dockerfile is partially based on: https://github.com/IBM-Swift/swift-ubuntu-docker/blob/master/swift-development/Dockerfile
FROM ibmcom/swift-ubuntu:3.0.2

# Upgrade and install basic Python dependencies
RUN apt-get -y update \
 && apt-get -y install --fix-missing python2.7 python-gevent python-flask zip

# Add the action proxy
RUN mkdir -p /actionProxy
ADD actionproxy.py /actionProxy

# Add files needed to build and run action
ADD . /swift3Action
RUN rm -rf .project .settings Dockerfile

# Build kitura net
RUN touch /swift3Action/spm-build/main.swift
RUN python /swift3Action/buildandrecord.py; rm /swift3Action/spm-build/.build/release/Action
ENV FLASK_PROXY_PORT 8080

CMD ["/bin/bash", "-c", "cd swift3Action && python -u swift3runner.py"]
