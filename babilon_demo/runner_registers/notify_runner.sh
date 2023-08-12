#!/bin/bash

gitlab-runner register \
  --non-interactive \
  --tls-ca-file="/etc/gitlab-runner/certs/192.168.3.240.crt" \
  --url "https://192.168.3.240:23443" \
  --registration-token "Qe7LvFRgFyPLkSbLtXNy" \
  --executor "docker" \
  --docker-image "docker:stable" \
  --description "notification_runner" \
  --tag-list "notification" \
  --run-untagged \
  --locked="false"

