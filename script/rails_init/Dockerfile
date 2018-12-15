FROM ruby:latest

RUN apt update && apt install -y \
      nodejs \
      mariadb-client \
      sqlite3

WORKDIR /app

COPY Gemfile  ./
COPY Gemfile.lock  ./

RUN bundle install

COPY . /{{1}}
