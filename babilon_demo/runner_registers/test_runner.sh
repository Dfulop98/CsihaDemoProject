#!/bin/bash

gitlab-runner register \
  --non-interactive \
  --tls-ca-file="/etc/gitlab-runner/certs/192.168.3.240.crt" \
  --url "https://192.168.3.240:23443" \
  --registration-token "glrt-zB6kGaTpHZmiemxTR1j8" \
  --executor "docker" \
  --docker-image "docker:stable" \
  --description "test_runner" \
  --tag-list "test" \
  --run-untagged \
  --locked="false"

