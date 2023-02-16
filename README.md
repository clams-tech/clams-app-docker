# clams-app-docker

This repo allows you to quickly self-host the Clams stack to a [modern docker engine](https://docs.docker.com/engine/) with [`docker compose (v2)`](https://docs.docker.com/compose/install/linux/). With this repo can can deploy:

* [browser-app](https://github.com/clams-tech/browser-app) - Available at [`http://127.0.0.1:8080`](http://127.0.0.1:8080) by default.
* [backend] - bitcoind+lightningd configured for native websocket support available at `ws://127.0.0.1:9735` by default.
* [ln-ws-proxy](https://github.com/clams-tech/ln-ws-proxy) - Proxy incoming `wss://` connections to lightning P2P (aka., 9735/tcp).

But first, you need to have a [working docker environment](https://docs.docker.com/engine/install/).

## How to use these scripts.

The only scripts you will need to run are [./up.sh](./up.sh) and maybe [./reset.sh](./reset.sh).

### ./up.sh

`./up.sh` brings up all your services as specified by variables in the [./.env](./.env) file. By default the backend and browser app are deployed. The core lightning node that gets deployed is configured to accept native websocket connections at `ws://127.0.0.1:9736`.

The output of `./up.sh` provides you with useful information like where all your services are located at. Also, when deploying your `backend`, it will spit out your node URI. This is the first piece of information you need when using the `browser-app`. The second piece of information you need is a functional rune. The script accepts a session ID (which the user copies from the [browser-app]) and produces a rune (admin only at the moment).

> Warning! Bitcoin `mainnet` is NOT SUPPORTED at this time.
### ./reset.sh

`./reset.sh` will destroy any artifacts generated in previous runs of your deployment. That way you start fresh when running `./up.sh` again.

### .env files

You can get more control your deployment by updating the  `.env` files in the various subdirectories. These files allow you to configure various aspects of the deployment including target git repo (useful for targeting a fork), git tag (to deploy a specific version), and service bindings (`ip:port`). By default everything is bound to `127.0.0.1`. You would update this variable here if you want to expose the service on a network interface.

> Note! TLS is outside the scope of this project!

## About Clams Stacks
### Browser-App

[`./browser-app/run.sh`](./browser-app/run.sh) builds the [Clams browser](https://github.com/clams-tech/browser-app) app using a Docker file all with the goal of getting the static HTML, JS, and CSS which (the build output). Then `docker compose up` is used to bring up [./browser-app/docker-compose.yml](./browser-app/docker-compose.yml). It's just a simple nginx web server which runs provides those files. By default you can access the self-hosted browser app at `http://127.0.0.1:8080` (address/port configurable).

> To actually use the `browser-app`, you will need a working core lightning node! (Hint: deploy the backend)!

### Backend

Want to start running Clams and testing with it locally? In order to do that, you need a functional core lightning node. The easiest way to get this is to run [./backend/run.sh](./backend/run.sh). The [bitcoind](https://hub.docker.com/r/polarlightning/bitcoind) and [core lightning](https://hub.docker.com/r/polarlightning/clightning) images [can be found at dockerhub](https://hub.docker.com/u/polarlightning).

> The backend was based on insights from [this article in the Clams docs](https://docs.clams.tech/testing-locally/).

### ln-ws-proxy

Similar to the Browser-app above, [`./ln-ws-proxy/run.sh`](./ln-ws-proxy/run.sh) starts by building the docker image for the [ln-ws-proxy](https://github.com/clams-tech/ln-ws-proxy). [./ln-ws-proxy/docker-compose.yml](./ln-ws-proxy/docker-compose.yml) defines an nginx reverse proxy which accepts http connections and proxies them to outbound TCP endpoints (lightning P2P).
