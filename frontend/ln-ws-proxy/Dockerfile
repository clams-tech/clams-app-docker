FROM node:18-buster

ARG GIT_REPO_URL
ARG VERSION

ENV VERSION=$VERSION
ENV GIT_REPO_URL=$GIT_REPO_URL

# we bind the service to all interfaces.
ENV HOST=0.0.0.0
ENV PORT=3000
#ENV RESTRICT_ORIGINS=

# bump the npm version to avoid notices
RUN npm install -g npm@9.6.0

# Clone the repository
RUN git clone $GIT_REPO_URL /ln-ws-proxy

# set the PWD of the.
WORKDIR /ln-ws-proxy

# checkout specific tag
RUN git -c advice.detachedHead=false checkout tags/$VERSION

# install dependencies
RUN yarn

# the service listens on TCP 3000
EXPOSE 3000

# default command is the run the application.
ENTRYPOINT [ "yarn", "start" ]
