# Alapkép beállítása
FROM dfulop98/my_gitlab_server:latest

COPY ./babilon_demo/restore.sh /restore.sh
COPY ./babilon_demo/backups/ /var/opt/gitlab/backups/
COPY ./babilon_demo/config_backups/ /etc/gitlab/config_backup/

RUN chmod +x /restore.sh


# entrypoint sh modify and rebuild a new one try other restore from video