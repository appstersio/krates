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
  rake compose:setup

# Skip running all the tests when we're in tracing mode
if [ "$TRACE" = "1" ];
then
  /bin/bash
else
  # End-2-end integration testing is desired
  rake
  popd
fi