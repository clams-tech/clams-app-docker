FROM node:latest

ARG GIT_REPO_URL
ARG VERSION

ENV VERSION=$VERSION

RUN apt-get update && apt-get install tzdata -y
ENV TZ="America/New_York"
RUN npm install -g npm@9.3.0

# Clone the repository
RUN git clone  /usr/src/ln-ws-proxy

# set the PWD of the.
WORKDIR /usr/src/ln-ws-proxy

# checkout specific tag
RUN git -c advice.detachedHead=false checkout tags/$VERSION

# install dependencies
RUN yarn

EXPOSE 3000

# default command is the run the application.
ENTRYPOINT [ "yarn", "start" ]
