FROM node:latest

ARG GIT_REPO_URL
ARG GIT_COMMIT

ENV GIT_COMMIT=$GIT_COMMIT

RUN mkdir /output
VOLUME /output
RUN mkdir /prism-app

# Clone the repository
RUN git clone $GIT_REPO_URL /prism-app

WORKDIR /prism-app

RUN git pull

EXPOSE 5173
ENV HOST=0.0.0.0
ENV PORT 5173

# checkout specific tag
RUN git -c advice.detachedHead=false checkout $GIT_COMMIT

RUN npm i
