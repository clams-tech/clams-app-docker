# clams-app-docker

## overview

This repo allows you get Clams running quickly in a [modern docker engine](https://docs.docker.com/engine/) using [`docker compose 3.8`](https://docs.docker.com/compose/compose-file/) and [docker swarm mode](`https://docs.docker.com/engine/swarm/`). The main scripts you need to know about are:

* [`./up.sh`](./up.sh) - brings up your Clams infrastructure according to [`./.env`](./.env).
* [`./down.sh`](./down.sh) - brings your Clams infrastructure down in a non-destructive way.
* [`./reset.sh`](./reset.sh) - this is just a non-destructuve `down.s.

If you leave [`./.env`](./.env) unmodified, you will get a single bitcoind and a single core lightning node running on regtest. In addition, the clams [browser-app](https://github.com/clams-tech/browser-app) becomes available on port 80/443. You backend primed to accept RPC calls using the websocket interface available on core lightning.

By updating [`./.env`](./.env), you can override anything specified in [`./defaults.env`](./defaults.env). The most important are the Global Settings. From here you can specify WHETHER to deploy TLS and if so, the [`fqdn`](https://en.wikipedia.org/wiki/Fully_qualified_domain_name) of the clams host (CLAMS_FQDN). Since we are using docker stacks, services are exposed on ALL IP addresses (so you cannot specify a bind address).

## scaling CLN Nodes

You can deploy multiple cln nodes if you desire. (This could be useful useful for classroom settings). All cln nodes that get deployed use the same bitcoin backend, and everything is configured to run the same `BTC_CHAIN`. All CLN nodes are configured to listen using the experimental websocket feature. All services are ultimately exposed by a single `nginx` container that exposes tcp/80 and tcp/443.

> When `ENABLE_TLS=true` you MUST forward ports 80/tcp and 443/tcp during certificate issuance and renewal (i.e., PUBLIC->IP_ADDRESS:80/443) for everything to work.

## conclusion

The output of `./up.sh` provides you with useful information like service endpoints. The scripts also emit node URI from the CLN nodes that get deployed. This is the first piece of information you need when using the the clams browser app. The second piece of information you need is a functional rune. The script accepts a session ID (which the user copies from the [browser-app]) and produces a rune.


# TODO

1. Add option for creating QR codes that contain NODE_URI+RUNE information so they can be printed on a postcard. Then clams browser app could scan that BASE64 encoded URI as query string parameters.