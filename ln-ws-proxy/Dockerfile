FROM node:18-buster

ARG GIT_REPO_URL
ARG VERSION

ENV VERSION=$VERSION
ENV GIT_REPO_URL=$GIT_REPO_URL

ENV HOST=0.0.0.0
ENV PORT=3000
#ENV RESTRICT_ORIGINS=

#RUN npm install -g npm@9.3.1

# Clone the repository
RUN git clone $GIT_REPO_URL /ln-ws-proxy

# set the PWD of the.
WORKDIR /ln-ws-proxy

# checkout specific tag
#RUN git -c advice.detachedHead=false checkout tags/$VERSION

#RUN npm i node-linux-x64
#RUN npm i uws_linux_x64_111
#RUN npm install 

# install dependencies
#RUN yarn add uWebSockets.js@uNetworking/uWebSockets.js#v20.10.0
RUN yarn
RUN yarn build

# the service listens on TCP 3000
EXPOSE 3000

# default command is the run the application.
ENTRYPOINT [ "yarn", "start" ]
