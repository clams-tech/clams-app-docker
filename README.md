# clams-app-docker

This repo allows you get Clams running quickly in a [modern docker engine](https://docs.docker.com/engine/) using [`docker compose (v2)`](https://docs.docker.com/compose/compose-file/). The main scripts you need to know about are:

* [`./up.sh`](./up.sh) - brings up your Clams infrastructure according to [`./.env`](./.env).
* [`./down.sh`](./down.sh) - brings your Clams infrastructure down in a non-destructive way.
* [`./reset.sh`](./reset.sh) - resets any temporary data or files from previous deployment attempts, allowing you to run [`./up.sh`](./up.sh) again.

If you leave [`./.env`](./.env) unmodified, you will get 1) bitcoind 2) core lightning (both on regtest), and 3) the [browser-app](https://github.com/clams-tech/browser-app) accessible at [`http://localhost:80`](http://localhost:80). Core lightning is configured to listen using the experimental websocket feature and is available at `ws://localhost:9736`. All services are ultimately exposed by a single `nginx` container that binds to whatever is specified in `BIND_ADDR`.

By updating [`./.env`](./.env), you can override anything specified in [`./defaults.env`](./defaults.env). The most important are the Global Settings. From here you can specify WHETHER to deploy TLS, the IP address to bind to, and the FQDN of the clams host. If you're going to enable TLS, then you MUST update CLAMS_FQDN and BIND_ADDR as well. Whatever you set CLAMS_FQDN to MUST be resolvable by the DNS.

> When `ENABLE_TLS=true` you MUST forward ports 80/tcp and 443/tcp during certificate issuance and renewal (i.e., PUBLIC->BIND_ADDR:80/443) for everything to work.

You can see all the configuration options below:

```bash

# uncomment and update to override defaults.env

# # Global Settings
# CLAMS_FQDN=clams.domain.tld
# BIND_ADDR=192.168.1.50
# ENABLE_TLS=true

# # browser app
# DEPLOY_BROWSER_APP=false
# BROWSER_APP_EXTERNAL_PORT=80
# BROWSER_APP_GIT_REPO_URL=https://github.com/clams-tech/browser-app.git
# BROWSER_APP_GIT_TAG=1.5.0

# # backend (bitcoind/clightning)
# DEPLOY_BTC_BACKEND=false
# BTC_CHAIN=testnet
# CLIGHTNING_WEBSOCKET_EXTERNAL_PORT=7272
# CLIGHTNING_P2P_EXTERNAL_PORT=9735

# # ln-ws-proxy
# DEPLOY_LN_WS_PROXY=true
# LN_WS_PROXY_HOSTNAME=lnwsproxy.domain.tld
# LN_WS_PROXY_GIT_REPO_URL=https://github.com/clams-tech/ln-ws-proxy.git
# LN_WS_PROXY_GIT_TAG=0.05
```

The output of `./up.sh` provides you with useful information like service endpoints. Once available, the scripts emit node URI from the core lightning node that gets deployed. This is the first piece of information you need when using the `browser-app`. The second piece of information you need is a functional rune. The script accepts a session ID (which the user copies from the [browser-app]) and produces a rune.

> Warning! Bitcoin `mainnet` is NOT SUPPORTED at this time.
### ./reset.sh

`./reset.sh` will destroy any artifacts generated in previous runs of your deployment. That way you start fresh when running `./up.sh` again.

### ln-ws-proxy

Similar to the `browser-app` above, [`./ln-ws-proxy/run.sh`](./ln-ws-proxy/run.sh) starts by building the docker image for [ln-ws-proxy](https://github.com/clams-tech/ln-ws-proxy). [./ln-ws-proxy/docker-compose.yml](./ln-ws-proxy/docker-compose.yml) defines an nginx reverse proxy which accepts http connections and proxies them to outbound TCP endpoints (lightning P2P).
