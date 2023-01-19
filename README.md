# clams-app-docker
Docker resources for hosting Clams App easily

## browser-app

The only script you need to run is `run.sh`. This script builds the Dockerfile for the Clams `browser-app` and saves the resulting static HTML files in a folder (`www-root` by default). You can specify the output directory by passing the `--output-path=/path/to/file` argument. `run.sh` loads the environment variables in `./env` and passes those variables into the `docker build` process. This results in a docker image that tracks the intended git repo (a specific tag) on the target git repo.

After the image is built, `run.sh` executes the image, which copies the resulting project files to the output path. When complete, the path contains all the static HTML, CSS, and JS that you can serve from any web server.

### nginx example config

TODO

```text
CONFIG EXAMPLES

```

## ln-ws-proxy

