#!/bin/bash
set -ue

pushd cli && \
  gem build kontena-cli.gemspec && \
  gem install *.gem && \
  kontena -v

popd

pushd test && \
  bundle install && \
  kontena -v && \
  rake compose:setup && \
  rake

popd