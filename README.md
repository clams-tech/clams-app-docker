# clams-app-docker

This repo allows you to quickly self-host Clams web server and ln-ws-proxy component in a docker environment.

## browser-app

The only script you need to run is [`run.sh`](./browser-app/run.sh). This `run.sh` calls [`build.sh`](./browser-app/build.sh) which builds docker image for the Clams `browser-app` and saves the resulting static HTML files in a folder (`www-root` by default). You can specify the output directory by passing the `--output-path=/path/to/output` argument. [`run.sh`](./browser-app/run.sh) loads the environment variables in [`./env`](./browser-app/env) and passes those variables into the `docker build` process. This results in a docker image that tracks the intended git repo and builds the code at the specified git tag.

After the image is built, [`run.sh`](./browser-app/run.sh) executes the image which copies the build output to the output path. When complete, the path contains all the static HTML, CSS, and JS needed by your web server, all owned by the user runnin the script. `200.html` is your server entrypoint (i.e., `www-root`).

### nginx example config

An nginx config example for hosting the browser-app is shown below.

```nginx
TODO
```

## ln-ws-proxy

The `ln-ws-proxy` is long-running server-side process. When run, the [`ln-ws-proxy/run.sh`](./ln-ws-proxy/run.sh) script builds the image file for the project then executes a long-running process which listens at `127.0.0.1:3000/tcp`. 

> Note! If you run host firewall, check your rules to ensure the port is permitted from localhost.

### nginx config

The nginx config below demonstrates how to terminate the WebSocket connection and proxy the requests to the `ln-ws-proxy` service.

```nginx
# HTTP redirect to HTTPS
server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name wsproxy.domain.tld;
        return 301

        https://$server_name$request_uri;
}

# Virtual Host/SSL/Reverse proxy configuration for example.com
server {
        listen 443 ssl;
        ssl_certificate <PATH_TO_CERTIFICATE>
        ssl_certificate_key <PATH_TO_CERTIFICATE_KEY>
        include <PATH_TO_SSL_CONF>
        ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

        server_name wsproxy.domain.tld;

        location / {
                # 127.0.0.1:3000 is the ln-ws-proxy service.
                proxy_pass http://127.0.0.1:3000;
                proxy_http_version 1.1;
                proxy_set_header Upgrade $http_upgrade;
                proxy_set_header Connection 'upgrade';
                proxy_set_header Host $host;
                proxy_cache_bypass $http_upgrade;
        }
}

```
