# clams-app-docker
Docker resources for hosting Clams App easily

## sub

The purpose of this script is to use a Docker container to get and build the Clams
project (we keep the client files only) to be served by the nginx front-end at https://clams.domain.tld
When the clams app makes a connection back to the node, 
it'll use the WebSocket support of core lightning to connect.

search "websocket" at https://lightning.readthedocs.io/lightningd-config.5.html?highlight=websocket
using the above websocket thing in core lightning LIKELY requires that I have a TLS certificate for
btcpay.domain.tld (e.g., 9736 for websocket, 9735 for lightnign binary); 
web clients will connect to potentially a different port for the websocket part


## version

The `version` file in this directory is what gets built into the docker container. It MUST match a git tag on the https://github.com/clams-tech/browser-app.git repo.
