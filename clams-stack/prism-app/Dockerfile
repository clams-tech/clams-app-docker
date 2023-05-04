FROM node:19.7

ARG GIT_REPO_URL
ARG VERSION

ENV VERSION=$VERSION

RUN mkdir /output
VOLUME /output
RUN mkdir /prism-app

# Clone the repository
RUN git clone $GIT_REPO_URL /prism-app

WORKDIR /prism-app

EXPOSE 5173
ENV HOST=0.0.0.0
ENV PORT 5173

# checkout specific tag
RUN git -c advice.detachedHead=false checkout $VERSION

RUN npm i
