#!/bin/sh

set -ue
BUNDLER_VERSION=2.1.4

# login
echo :rubygems_api_key: $RUBYGEMS_KEY > ~/.gem/credentials
chmod 0600 ~/.gem/credentials
# curl -u $RUBYGEMS_USER https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials; chmod 0600 ~/.gem/credentials

# install dependencies
gem install bundler --version $BUNDLER_VERSION
gem install rake colorize dotenv

# cd $TRAVIS_BUILD_DIR
rake release:setup
rake release:push_gem

# cleanup
rm ~/.gem/credentials
