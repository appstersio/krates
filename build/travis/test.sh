#!/bin/bash
set -ue

 # CVE-2018-1000539 is a vulnerability in JSON-JWT, used by ancient Acme::Client for sending requests, not for validating.
cd $TEST_DIR && \
  bundle config set path 'vendor/bundle' && \
  bundle audit check --update --ignore CVE-2018-1000539 CVE-2019-16779 && \
  bundle exec rspec spec/
