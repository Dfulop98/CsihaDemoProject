#!/bin/bash

chown git.git /etc/gitlab/config_backup/gitlab_config_1691933782_2023_08_13.tar
chown git.git /var/opt/gitlab/backups/1691933738_2023_08_13_16.2.3_gitlab_backup.tar
gitlab-ctl stop unicorn
gitlab-ctl stop puma
gitlab-ctl stop sidekiq
tar -xvf /etc/gitlab/config_backup/gitlab_config_1691933782_2023_08_13.tar -C /etc/gitlab
gitlab-backup restore BACKUP=1691933738_2023_08_13_16.2.3
gitlab-ctl start unicorn
gitlab-ctl start puma
gitlab-ctl start sidekiq
gitlab-ctl reconfigure
gitlab-ctl restart
gitlab-rake gitlab:check SANITIZE=true