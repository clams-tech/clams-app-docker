# clams-app-docker
Docker resources for hosting Clams App easily

## browser-app

The only script you need to run is `run.sh`. This script builds the Dockerfile for the Clams `browser-app` and saves the resulting static HTML files in a folder (`www-root` by default). You can specify the output directory by passing the `--output-path=/path/to/output` argument. `run.sh` loads the environment variables in `./env` and passes those variables into the `docker build` process. This results in a docker image that tracks the intended git repo and builds the code at the specified git tag.

After the image is built, `run.sh` executes the image which copies the build output to the output path. When complete, the path contains all the static HTML, CSS, and JS needed by your web server. `200.html` is your server entrypoint (i.e., `www-root`). 

### nginx example config

An nginx config example for hosting the browser-app is shown below.

```text
TODO

```

## ln-ws-proxy

The structure for `ln-ws-proxy` is a bit simpler. The `ln-ws-proxy` is long-running server-side process. When run, the `ln-ws-proxy/run.sh` script builds the image file for the project then executes a long-running process which listens at `127.0.0.1:3000/tcp`. Note! If you run host firewall, check your rules to ensure the port is permitted from localhost.

### nging config

An nginx config example for hosting the browser-app is shown below.

```text
TODO

```