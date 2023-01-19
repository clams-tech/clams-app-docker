#!/bin/bash

# this script publishes docker images to dockerhub.com
# it first invokes the build command. Then it pushs those 
# to docker hub. Note you MUST have the correct dockerhub credentials
# to push to the remote respository.

./buld.sh

docker push X
docker push X