# clams-app-docker
Docker resources for hosting Clams App easily

# browser-app

This folder contains a build script and a run script. When you execute build.sh, the env file is loaded and used to eventually get to the docker build command. In that command, we pass --build-args into the Docker build process. This results in a docker file that tracks the right git repo and tag that we want to target.

When you execute the the run script, the docker container creates a new directory: www-root. The container copies the results of the browser-app build process into the www-root folder.

## nginx example config

TODO

```text
CONFIG EXAMPLES

```