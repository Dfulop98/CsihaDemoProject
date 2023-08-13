
FROM dfulop98/my_gitlab_server:latest

COPY ./babilon_demo/backups/restore.sh /restore.sh
COPY ./babilon_demo/backups/data/ /var/opt/gitlab/backups/
COPY ./babilon_demo/backups/config/ /etc/gitlab/config_backup/

RUN chmod +x /restore.sh

