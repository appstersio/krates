#!/bin/sh

set -ue

# login
docker login -u $DOCKER_HUB_USER -p $DOCKER_HUB_PASSWORD

# install dependencies
gem install colorize dotenv middleman

rake release:setup
rake release:push