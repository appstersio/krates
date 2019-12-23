#!/bin/bash

echo ":: RUBY ::"
ruby -v
echo

echo ":: BUNDLE ::"
bundle env
echo

if [ "$TEST_DIR" = "server" ]; then
  echo ":: MONGO DB ::"
  docker run -d -p 27017:27017 --rm --name mongo mongo:3.6 mongod --smallfiles
  sleep 5s
  docker logs mongo
  echo
fi

echo ":: BEFORE INSTALL ::"
gem install bundler-audit --no-document
echo