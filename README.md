# clams-app-docker

## overview

This repo allows you get run lightning-based browser apps quickly in a [modern docker engine](https://docs.docker.com/engine/) using [`docker compose 3.8`](https://docs.docker.com/compose/compose-file/) and [docker swarm mode](`https://docs.docker.com/engine/swarm/`). The main scripts you need to know about are:

* [`./install.sh`](install.sh) - this script installs docker and other utilities needed to run the rest of this software.
* [`./up.sh`](./up.sh) - brings up your Clams infrastructure according to [`./.env`](./.env).
* [`./down.sh`](./down.sh) - brings your Clams infrastructure down in a non-destructive way.
* [`./reset.sh`](./reset.sh) - this is just a non-destructuve `down.sh`, the `up.sh`. Just save a step.

If you leave [`./.env`](./.env) unmodified, you will get a 4 CLN nodes running on regtest, all connnected to a single bitcoind backend. In addition, the [prism-browser-app](https://github.com/johngribbin/ROYGBIV-frontend) becomes available on port 80/443 at `https://$DOMAIN_NAME`. Each CLN node is configured to accept websocket connections from remote clients.

By updating [`./.env`](./.env), you can override anything specified in [`./defaults.env`](./defaults.env). The most important are the Global Settings. From here you can specify WHETHER to deploy TLS and if so, the [`fqdn`](https://en.wikipedia.org/wiki/Fully_qualified_domain_name) of the clams host (CLN_FQDN). Since we are using docker stacks, services are exposed on ALL IP addresses (so you cannot specify a bind address). This is usually fine if you're running a dedicated VM in the cloud, but if you're self-hosting, ensure the host is isolated on a DMZ.

## signet

If you want to run signet, set BTC_CHAIN=signet in .env. By default this runs the public signet which has a 10 minute block time. The plan is to add a [private signet](https://blog.mutinywallet.com/mutinynet/) with configurable blocktimes. This is useful for lab or educational settings where waiting 10 minutes for channel creation is untenable.

## scaling CLN Nodes

You can deploy multiple cln nodes if you desire. (This could be useful useful for classroom settings). All cln nodes that get deployed use the same bitcoin backend, and everything is configured to run the same `BTC_CHAIN`. All CLN nodes are configured to listen using the experimental websocket feature and are exposed on different ports at the reverse proxy. All services are ultimately exposed by a single `nginx` container that exposes tcp/80 and tcp/443, as well as TLS termiantions for the websocket connections of all the CLN nodes.

If you deploy three CLN nodes, for example, you'll be able to access their respective websocket interfaces at 

```
wss://CLAMS_HOST:9736
wss://CLAMS_HOST:9737
wss://CLAMS_HOST:9738
```

> When `ENABLE_TLS=true` you MUST forward ports 80/tcp and 443/tcp during certificate issuance and renewal (i.e., PUBLIC->IP_ADDRESS:80/443) for everything to work.

## conclusion

The output of `./up.sh` provides you with useful information like service endpoints. The scripts also emit node URI from the CLN nodes that get deployed. This is the first piece of information you need when using the the clams browser app. The second piece of information you need is a functional rune. The script accepts a session ID (which the user copies from the [browser-app]) and produces a rune.

## spinning up a new VM in a cloud proder

Ok so lets say you want to create a server in the cloud so you can run this repo on it. All we assume is you're running ubuntu 22.04 server. After getting SSH access the to VM, you can clone this repo, then run `./install.sh`. Then usually you want to log out to refresh group membership. After that, your VM should be ready for `./up.sh`. 


# TODO

1. Make default deployment a regtest network consisting of 5 CLN nodes all with channels created optimized for testing prisms. (farscapian)
2. Make all deployments variable in size with different channel establishement mechanisms. (derek)
3. Add option for creating QR codes that contain NODE_URI+RUNE information so they can be printed on a postcard. Then clams browser app could scan that BASE64 encoded URI as query string parameters. (derek)
4. Finish integrating https://github.com/johngribbin/ROYGBIV-frontend at https://roygbiv.money (ethan)

## Other Notes

1. Damien is editing prism.py -- derek is not. Goal is to get eventual plugin pulled into the community list.
