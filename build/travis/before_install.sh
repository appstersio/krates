#!/bin/sh

if [ "$TEST_DIR" = "server" ]; then
  docker run -d -p 27017:27017 --rm --name mongo mongo:3.6 mongod --smallfiles
  sleep 5s
  docker logs mongo
fi

gem update --system
gem install bundler-audit