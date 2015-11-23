############################
# NGINX reverse proxy for Dockerized Jenkins master
# Inspired by https://engineering.riotgames.com/news/jenkins-docker-proxies-and-compose
# and https://www.digitalocean.com/community/tutorials/how-to-configure-nginx-with-ssl-as-a-reverse-proxy-for-jenkins
############################

FROM marvambass/nginx-ssl-secure

#
# See https://github.com/MarvAmBass/docker-nginx-ssl-secure#cheat-sheet
# TODO: replace CN=jenkins.example.com with final, shared Jenkins FQDN
#
RUN \
    openssl dhparam -out /etc/nginx/external/dh.pem 2048 && \
    openssl req -x509 -newkey rsa:4086 \
        -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=jenkins.example.com" \
        -keyout "/etc/nginx/external/key.pem" \
        -out "/etc/nginx/external/cert.pem" \
        -days 3650 -nodes -sha256

#
# Copy Jenkins conf into container
#
COPY conf/jenkins.conf /etc/nginx/external/
