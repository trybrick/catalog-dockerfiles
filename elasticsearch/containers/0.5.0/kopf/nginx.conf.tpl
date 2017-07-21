daemon off;
user www-data;
worker_processes 4;
pid /run/nginx.pid;

events {
  worker_connections 8192;
}

http {
  sendfile                        on;
  tcp_nopush                      on;
  tcp_nodelay                     on;
  client_header_timeout           1m;
  client_body_timeout             1m;
  client_header_buffer_size       2k;
  client_body_buffer_size         256k;
  client_max_body_size            256m;
  large_client_header_buffers     4   8k;
  send_timeout                    30;
  keepalive_timeout               60 60;
  reset_timedout_connection       on;
  server_tokens                   off;
  server_name_in_redirect         off;
  server_names_hash_max_size      512;
  server_names_hash_bucket_size   512;

  include /etc/nginx/mime.types;
  default_type application/octet-stream;

  access_log /dev/stdout;
  error_log /dev/stderr;

  # Compression settings - aggressively cache text file types
  gzip                            on;
  gzip_comp_level                 9;
  gzip_min_length                 512;
  gzip_buffers                    8 64k;
  gzip_types                      text/plain text/css text/javascript text/js text/xml application/json application/javascript application/x-javascript application/xml application/xml+rss application/x-font-ttf image/svg+xml font/opentype;
  gzip_proxied                    any;
  gzip_disable "MSIE [1-6]\.";

  upstream es {
    {% for server in KOPF_ES_SERVERS.split(",") %}
    server {{ server }};
    {% endfor %}
  }

  {% if KOPF_SSL_CERT is defined %}
  server {
    listen 80;
    server_name {{ KOPF_SERVER_NAME }};
    return 301 https://{{ KOPF_SERVER_NAME }}$request_uri;
  }
  {% endif %}

  server {
    {% if KOPF_SSL_CERT is defined %}
    listen 443 ssl;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
    ssl_certificate {{ KOPF_SSL_CERT }};
    ssl_certificate_key {{ KOPF_SSL_KEY }};
    {% else %}
    listen 80;
    {% endif %}

    server_name {{ KOPF_SERVER_NAME }};

    satisfy any;

    {% if KOPF_BASIC_AUTH_LOGIN is defined %}
    auth_basic "Access restricted";
    auth_basic_user_file /etc/nginx/kopf.htpasswd;
    {% endif %}

    {% if KOPF_NGINX_INCLUDE_FILE is defined %}
    include {{ KOPF_NGINX_INCLUDE_FILE }};
    {% endif %}

    # suppress passing basic auth to upstreams
    proxy_set_header Authorization "";

    # everybody loves caching bugs after upgrade
    expires -1;

    location / {
      proxy_pass http://es;
    }
  }
}
