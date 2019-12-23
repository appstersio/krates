#!/bin/bash

echo ":: RUBY ::"
ruby -v
echo

echo ":: BUNDLE ::"
bundle env
echo

if [ "$TEST_DIR" = "server" ]; then
  docker run -d -p 27017:27017 --rm --name mongo mongo:3.6 mongod --smallfiles
  sleep 5s
  docker logs mongo
fi
echo

echo ":: BEFORE INSTALL ::"
gem install bundler-audit --no-document
echo