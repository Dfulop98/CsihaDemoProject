#!/bin/bash

chown git.git /var/opt/gitlab/backups/1691949551_2023_08_13_16.2.3_gitlab_backup.tar
gitlab-ctl stop unicorn
gitlab-ctl stop puma
gitlab-ctl stop sidekiq
gitlab-backup restore BACKUP=1691949551_2023_08_13_16.2.3
gitlab-ctl start unicorn
gitlab-ctl start puma
gitlab-ctl start sidekiq
gitlab-ctl reconfigure
gitlab-ctl restart
gitlab-rake gitlab:check SANITIZE=true