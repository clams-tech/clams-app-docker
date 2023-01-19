FROM node:18

ARG GIT_REPO_URL
ARG VERSION

ENV VERSION=$VERSION

RUN apt-get update && apt-get install tzdata -y
ENV TZ="America/New_York"
RUN npm install -g npm@9.3.0

# Clone the repository
RUN git clone $GIT_REPO_URL /browser-app

WORKDIR /browser-app

# checkout specific tag
RUN git -c advice.detachedHead=false checkout tags/$VERSION

# install dependencies
RUN yarn

# build the project.
RUN yarn build

RUN mkdir /output
VOLUME /output

# This command copies everything from 
ENTRYPOINT [ "cp", "-a", "/browser-app/build/.", "/output/" ]
