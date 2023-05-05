# prism-stack

## overview

This repo allows you to deploy lightning-based browser apps quickly in a [modern docker engine](https://docs.docker.com/engine/) using [docker swarm mode](`https://docs.docker.com/engine/swarm/`). The main scripts you need to know about are:

* [`./install.sh`](install.sh) - this script installs docker and other utilities needed to run the rest of this software.
* [`./up.sh`](./up.sh) - brings up your Clams infrastructure according to [`./.env`](./.env).
* [`./down.sh`](./down.sh) - brings your Clams infrastructure down in a non-destructive way.
* [`./reset.sh`](./reset.sh) - this is just a non-destructuve `down.sh`, the `up.sh`. Just save a step.

By updating [`./.env`](./.env), you can override anything specified in [`./defaults.env`](./defaults.env). The most important are the Global Settings. From here you can specify WHETHER to deploy TLS and and, importantly, which domain you want to deploy. Since we are using docker stacks, services are exposed on ALL IP addresses (you cannot specify a bind address). This is usually fine if you're running a dedicated VM in the cloud, but if you're self-hosting, ensure the host is isolated on a DMZ.

If you leave [`./.env`](./.env) unmodified, you will get a 5 CLN nodes running on regtest, all connnected to a single bitcoind backend. In addition, the [prism-browser-app](https://github.com/johngribbin/ROYGBIV-frontend) becomes available on port 80/443 at `https://domain.tld`. You may also deploy the [`clams-browser-app`](https://github.com/clams-tech/browser-app) at `https://clams.domain.tld` up updating `./.env`.

All CLN nodes are configured to accept [websocket connections](https://lightning.readthedocs.io/lightningd-config.5.html) from remote web clients. The nginx server that gets deployed terminates all client TLS sessions and proxies websocket requests to the appropriate CLN node based on port number. See `cln nodes` below.

## signet

If you want to run signet, set BTC_CHAIN=signet in .env. By default this runs the public signet which has a 10 minute block time. The plan is to add a [private signet](https://blog.mutinywallet.com/mutinynet/) with configurable blocktimes. This is useful for lab or educational settings where waiting 10 minutes for channel creation is untenable.

## cln nodes

You can deploy multiple cln nodes if you desire. (This could be useful useful for classroom settings). All cln nodes that get deployed use the same bitcoin backend, and everything is configured to run the same `BTC_CHAIN`. All CLN nodes are configured to listen using the experimental websocket feature and are exposed on different ports at the reverse proxy. All services are ultimately exposed by a single `nginx` container that exposes tcp/80 and tcp/443, as well as TLS termiantions for the websocket connections of all the CLN nodes.

If you deploy three CLN nodes, for example, you'll be able to access their respective websocket interfaces at 

```
wss://CLAMS_HOST:9736
wss://CLAMS_HOST:9737
wss://CLAMS_HOST:9738
```

> When `ENABLE_TLS=true` you MUST forward ports 80/tcp and 443/tcp during certificate issuance and renewal (i.e., PUBLIC->IP_ADDRESS:80/443) for everything to work.


## spinning up a new VM in a cloud proder

Ok so lets say you want to create a server in the cloud so you can run this repo on it. All we assume is you're running ubuntu 22.04 server. After getting SSH access the to VM you should copy the contents of ./install.sh and paste them into the remote VM (will try to automate this later). This installs dockerd in the instance. Then log out.

### DNS

When running in a public VM, you MUST use TLS (ENABLE_TLS=true). This means you need to set up DNS records for the system.

```
ALIAS,@,HOSTNAME_OF_REMOTE_VM_IN_CLOUD_PROVIDER
```

### SSH

```config
Host domain.tld
    User ubuntu
    IdentityFile /home/ubuntu/.ssh/domain.tld.pem
```

Ok, now run `ssh domain.tld` and ensure you can log into the VM before continuing.

### export DOCKER_HOST

Next, in your terminal, run `export DOCKER_HOST=ssh://ubuntu@domain.tld`. This instructs your local docker daemon to issue commands against the remote dockerd by tunneling over SSH.

After that, your VM should be ready for `./up.sh`, `./down.sh`, `./reset.sh`

## regtest setup

The default regtest setup consists of 1 bitcoin backend and 5 CLN nodes. After these nodes are deployed, they are funded then connected to each other over the p2p network. Then the following channels are opened, where `*` means all the initial btc is on that side of the channel, and `[n]` where n is the CLN index number.

1.  Bob*[0]->Alice[1]
2.  Alice*[1]->Carol[2]
3.  Alice*[1]->Diane[3]
4.  Alice*[1]->Betty[4]

This setup is ideal from a testing perspective. You can access each node using the deployed clams wallet. But the root domain goes to the prism app. Configure the `prism-browser-app` against Alice, who will create the prism and expose the BOLT12 offer. All payments to the BOLT12 offer can be done in Bob's Clams app.

### signet

TODO

#### Publc Signets

TODO
#### Private Signets

TODO
# TODO

1. Make default deployment a regtest network consisting of 5 CLN nodes all with channels created optimized for testing prisms. (farscapian)
2. Make all deployments variable in size with different channel establishement mechanisms. (derek)
3. Add option for creating QR codes that contain NODE_URI+RUNE information so they can be printed on a postcard. Then clams browser app could scan that BASE64 encoded URI as query string parameters. (derek)
4. Finish integrating https://github.com/johngribbin/ROYGBIV-frontend at https://roygbiv.money (ethan)

## Other Notes

1. Damien is editing prism.py -- derek is not. Goal is to get eventual plugin pulled into the community list.

## conclusion

The output of `./up.sh` provides you with useful information like service endpoints. The scripts also emit node URI from the CLN nodes that get deployed. This is the first piece of information you need when using the the clams browser app. The second piece of information you need is a functional rune. The script accepts a session ID (which the user copies from the [browser-app]) and produces a rune.