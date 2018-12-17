FROM ruby:latest

RUN apt update && apt install -y \
      sudo \
      nodejs \
      mariadb-client \
      sqlite3

ARG DOCKER_UID=1000
ARG DOCKER_USER=docker
ARG DOCKER_PASSWORD=docker
RUN useradd -m \
  --uid ${DOCKER_UID} --groups sudo --shell /bin/bash ${DOCKER_USER} \
  && echo ${DOCKER_USER}:${DOCKER_PASSWORD} | chpasswd

ARG APP=app
WORKDIR /${APP}

COPY Gemfile  /${APP}
COPY Gemfile.lock  /${APP}
RUN bundle install

COPY . /${APP}
