#!/bin/bash

gitlab-runner register \
  --non-interactive \
  --tls-ca-file="/etc/gitlab-runner/certs/192.168.3.240.crt" \
  --url "https://192.168.3.240:23443" \
  --registration-token "glrt-Nphj5Ro7aftq1vmAhfse" \
  --executor "docker" \
  --docker-image "mcr.microsoft.com/windows/nanoserver:ltsc2019" \
  --description "docker_runner" \
  --tag-list "dockerizer" \
  --run-untagged \
  --locked="false"

