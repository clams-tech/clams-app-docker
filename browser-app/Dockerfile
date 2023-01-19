FROM node:latest

ARG GIT_REPO_URL
ARG VERSION

ENV VERSION=$VERSION

RUN apt-get update && apt-get install tzdata -y
ENV TZ="America/New_York"
RUN npm install -g npm@9.3.0

# Clone the repository
RUN git clone $GIT_REPO_URL /usr/src/browser-app

WORKDIR /usr/src/browser-app

# checkout specific tag
RUN git -c advice.detachedHead=false checkout tags/$VERSION

# install dependencies
RUN yarn

# build the project.
RUN yarn build

# default command is the run the application.
ENTRYPOINT [ "yarn", "dev" ]
