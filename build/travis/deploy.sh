#!/bin/sh

set -ue
BUNDLER_VERSION=2.1.4

# login
docker login -u $DOCKER_HUB_USER -p $DOCKER_HUB_PASSWORD

# install dependencies
gem install bundler --version $BUNDLER_VERSION
gem install rake colorize dotenv middleman

rake release:setup
rake release:push