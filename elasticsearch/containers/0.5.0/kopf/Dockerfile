FROM nginx:1.13.3

# upgrade
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends python-pip curl nano && \
    rm -rf /var/lib/apt/lists/* && \
    pip install -U pip setuptools wheel && \
    pip install envtpl

# nginx
ADD nginx.conf.tpl /etc/nginx/nginx.conf.tpl

# run script
ADD ./run.sh ./run.sh

# kopf
ENV KOPF_VERSION 2.1.1
RUN curl -s -L "https://github.com/lmenezes/elasticsearch-kopf/archive/v${KOPF_VERSION}.tar.gz" | \
    tar xz -C /tmp && mv "/tmp/elasticsearch-kopf-${KOPF_VERSION}" /kopf

# logs
VOLUME ["/var/log/nginx"]

# ports
EXPOSE 80 443

ENTRYPOINT ["/run.sh"]
