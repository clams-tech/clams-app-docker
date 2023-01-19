# clams-app-docker
Docker resources for hosting Clams App easily

## browser-app

The only script you need to run is `run.sh`. This script builds the Dockerfile for the Clams `browser-app` and saves the resulting static HTML files in a folder `www-root`. `run.sh` loads the environment variables in `./env` and passes those variables into the `docker build` process. This results in a docker image that tracks the right git repo and tag on the target git repo.

After the image is built, `run.sh` executes the image, which copies the resulting project files to a local folder `www-root`. That folder contains all the HTML, CSS, and Javascript in static files that you can serve from any web server.

### nginx example config

TODO

```text
CONFIG EXAMPLES

```

## ln-ws-proxy

