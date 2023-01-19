FROM node:latest

ARG GIT_REPO_URL
ARG VERSION

ENV VERSION=$VERSION
ENV HOST=localhost
ENV PORT=3000
#ENV RESTRICT_ORIGINS=

#RUN apt-get update && apt-get install tzdata -y
#ENV TZ="America/New_York"
RUN npm install -g npm@9.3.1

# Clone the repository
RUN git clone $GIT_REPO_URL /usr/src/ln-ws-proxy

# set the PWD of the.
WORKDIR /usr/src/ln-ws-proxy

# checkout specific tag
RUN git -c advice.detachedHead=false checkout tags/$VERSION

# install dependencies
RUN yarn


RUN npm install


# the service listens on TCP 3000
EXPOSE 3000

# default command is the run the application.
CMD [ "yarn", "start" ]
