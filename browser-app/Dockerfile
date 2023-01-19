FROM node:latest

RUN apt-get update && apt-get install tzdata -y
ENV TZ="America/New_York"
RUN npm install -g npm@9.3.0

# Clone the repository
RUN git clone https://github.com/farscapian/browser-app.git /usr/src/clams
#https://github.com/clams-tech/browser-app.git

WORKDIR /usr/src/clams

# checkout specific tag
#RUN git -c advice.detachedHead=false checkout tags/1.3.0

# install dependencies
RUN yarn

# build the project.
RUN yarn build

# default command is the run the application.
ENTRYPOINT [ "yarn", "dev" ]
