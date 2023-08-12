#!/bin/bash

gitlab-runner register \
  --non-interactive \
  --tls-ca-file="/etc/gitlab-runner/certs/192.168.3.240.crt" \
  --url "https://192.168.3.240:23443" \
  --registration-token "glrt-6kS-74CxppUbzMMUJfky" \
  --executor "docker" \
  --docker-image "docker:stable" \
  --description "archive_runner" \
  --tag-list "archive" \
  --run-untagged \
  --locked="false"

