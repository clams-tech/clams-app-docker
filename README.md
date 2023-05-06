# prism-stack

## overview

This repo allows you to deploy the `roygbiv-prism` stack quickly in a [modern docker engine](https://docs.docker.com/engine/) using [docker swarm mode](`https://docs.docker.com/engine/swarm/`). The main scripts you need to know about are:

* [`./install.sh`](install.sh) - this script installs dockerd and other utilities needed to run the rest of this software.
* [`./up.sh`](./up.sh) - brings up your the `roygbiv stack` according to your `env` file (defined in `./environments`).
* [`./down.sh`](./down.sh) - brings your `roygbiv stack` down in a non-destructive way.
* [`./reset.sh`](./reset.sh) - this is just a non-destructuve `down.sh`, the `up.sh`. Just save a step.

You can specify your env file to customize your deployment. First create a file looking something like below in `./environments/domain.tld`. Then enter `domain.tld` in [`./active_env`](./active_env)

```config
DOCKER_HOST=ssh://ubuntu@domain.tld
DOMAIN_NAME=domain.tld
ENABLE_TLS=true
```

An `env` file overrides anything in [`./defaults.env`](./defaults.env). You can specify whether to deploy TLS and importantly, which domain you want to use (note this MUST be publicly resolvable in the DNS AND ports 80 and 443 are REQUIRED for certificate issuance and renewal). 

Since we are using docker stacks, services are exposed on ALL IP addresses (you cannot specify a bind address). This is usually fine if you're running a dedicated VM in the cloud, but if you're self-hosting, ensure the host is on a protected DMZ.

If you don't specify an `env` file, you will get a default set of five CLN nodes running on regtest, all connnected to a single bitcoind backend. In addition, the [prism-browser-app](https://github.com/johngribbin/ROYGBIV-frontend) becomes available on port 80/443 at `https://domain.tld`. You may also deploy the [`clams-browser-app`](https://github.com/clams-tech/browser-app) at `https://clams.domain.tld` by updating your `env` file. All CLN nodes are configured to accept [websocket connections](https://lightning.readthedocs.io/lightningd-config.5.html) from remote web clients. The nginx server that gets deployed terminates all client TLS sessions and proxies websocket requests to the appropriate CLN node based on port number. See `cln nodes` below.

```
wss://CLAMS_HOST:9736
wss://CLAMS_HOST:9737
wss://CLAMS_HOST:9738
```

> When `ENABLE_TLS=true` you MUST forward ports 80/tcp and 443/tcp during certificate issuance and renewal (i.e., PUBLIC->IP_ADDRESS:80/443) for everything to work.

## spinning up a new VM in a cloud provider

Ok so lets say you want to create a server in the cloud so you can run this `roygbiv-stack`. All we assume is you're running ubuntu 22.04 server. After getting SSH access the to VM you should copy the contents of ./install.sh and paste them into the remote VM (will try to automate this later). This installs dockerd in the instance. Then log out.

### DNS

When running in a public VM, you MUST use TLS (ENABLE_TLS=true). This means you need to set up DNS records for the system. The best setup is an ALIAS record which points to the DNS name provided by your hosting provider. If you want to deploy the Clams browser-app, you will need a CNAME for `clams.domain.tld`.

```
ALIAS,@,HOSTNAME_OF_REMOTE_VM_IN_CLOUD_PROVIDER
```

### SSH

You will also want to ensure that your `~/.ssh/config` file has a host defined for the remote host. An example is show below. `domain.tld.pem` is the SSH private key that enables you to SSH into the remote VM that is resolvele to `domain.tld`.

```
Host domain.tld
    User ubuntu
    IdentityFile /home/ubuntu/.ssh/domain.tld.pem
```

Ok, now run `ssh domain.tld` and ensure you can log into the VM before running any scripts (up/down/reset).

## regtest setup

The default regtest setup consists of a single bitcoind backend and five CLN nodes. After these nodes are deployed, they are funded then connected to each other over the p2p network. Then the following channels are opened, where `*` means all the initial btc is on that side of the channel, and `[n]` where n is the CLN index number.

1.  Bob*[0]->Alice[1]
2.  Alice*[1]->Carol[2]
3.  Alice*[1]->Diane[3]
4.  Alice*[1]->Betty[4]

This setup is useful for testing lightning prisms. If you want control a node, open [clams-wallet](https://app.clams.tech) and enter the Node URI provided. Using Clams, you can pay invoices on Bob and watch incoming payments on Carol, Diana, and Betty.

Configure the `prism-browser-app` against Alice, who will create the prism and expose the BOLT12 offer. All payments to the BOLT12 offer can be done in Bob's Clams app.

### signet

STATUS: NOT COMPLETELY IMPLEMENTED

If you want to run signet, set BTC_CHAIN=signet in .env. By default this runs the public signet which has a 10 minute block time. The plan is to add a [private signet](https://blog.mutinywallet.com/mutinynet/) with configurable blocktimes. This is useful for lab or educational settings where waiting 10 minutes for channel creation is untenable.


#### Publc Signets

TODO
#### Private Signets

TODO
## QR codes

STATUS: NOT STARTED
DESCRIPTION: Add option for creating QR codes that contain url-encoded BASE64(NODE_URI+RUNE) information so they can be printed on a postcard and scanned by browser-apps for quicly connecting to your node. This requires that the browser app is capable of parsing the query string parameters.