FROM ruby:latest

RUN apt update && apt install -y \
      nodejs \
      mariadb-client

ARG APP=app
WORKDIR /${APP}
COPY ./ ./
RUN bundle install --path vendor/bundle --jobs=4
