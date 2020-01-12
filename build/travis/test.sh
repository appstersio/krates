#!/bin/bash
set -ue

echo ":: TEST ::"
 # CVE-2018-1000539 is a vulnerability in JSON-JWT, used by ancient Acme::Client for sending requests, not for validating.
pushd $TEST_DIR
bundle install

if [ "$TRACE" = "1" ];
then
  /bin/bash
else
  bundle audit check --update --ignore CVE-2018-1000539 CVE-2019-16779
  bundle exec rspec spec/
fi

echo