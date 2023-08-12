#!/bin/bash

gitlab-runner register \
  --non-interactive \
  --tls-ca-file="/etc/gitlab-runner/certs/192.168.3.240.crt" \
  --url "https://192.168.3.240:23443" \
  --registration-token "glrt-xPGszsm8V6f_QyecRyUS" \
  --executor "docker" \
  --docker-image "docker:stable" \
  --description "build_runner" \
  --tag-list "build" \
  --run-untagged \
  --locked="false"

