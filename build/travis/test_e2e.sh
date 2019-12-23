#!/bin/bash
set -ue

pushd cli && \
  gem build kontena-cli.gemspec && \
  gem install *.gem && \
  kontena -v

popd

pushd test && \
  bundle config set system 'true' && \
  bundle config set without 'development' && \
  bundle install && \
  kontena -v && \
  rake compose:setup && \
  rake

popd