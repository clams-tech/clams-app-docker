FROM node:latest

ARG GIT_TAG

RUN apt-get update && apt-get install tzdata -y
ENV TZ="America/New_York"
RUN npm install -g npm@9.3.0

# Clone the repository
RUN git clone https://github.com/clams-tech/ln-ws-proxy.git /usr/src/ln-ws-proxy

# set the PWD of the.
WORKDIR /usr/src/ln-ws-proxy

# checkout specific tag
#RUN git -c advice.detachedHead=false checkout tags/1.3.0

# install dependencies
RUN yarn

EXPOSE 3000

# default command is the run the application.
ENTRYPOINT [ "yarn", "start" ]
