# Alapkép beállítása
FROM gitlab/gitlab-ce:latest

COPY ./certs /etc/ssl
# Környezeti változók beállítása
ENV GITLAB_OMNIBUS_CONFIG="external_url 'https://192.168.3.240'; \
    letsencrypt['enable'] = false; \
    nginx['redirect_http_to_https'] = false; \
    nginx['ssl_certificate'] = '/etc/ssl/192.168.3.240.crt'; \
    nginx['ssl_certificate_key'] = '/etc/ssl/192.168.3.240.key'"

# SSL script és egyéb szükséges fájlok másolása a képbe

