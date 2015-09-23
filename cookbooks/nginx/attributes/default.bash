#!/bin/bash -e

export NGINX_DOWNLOAD_URL='http://nginx.org/download/nginx-1.9.5.tar.gz'
export NGINX_PCRE_DOWNLOAD_URL='ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz'
export NGINX_ZLIB_DOWNLOAD_URL='http://zlib.net/zlib-1.2.8.tar.gz'

export NGINX_INSTALL_FOLDER='/opt/nginx'

export NGINX_SERVICE_NAME='nginx'

export NGINX_USER_NAME='nginx'
export NGINX_GROUP_NAME='nginx'

export NGINX_PORT='80'

export NGINX_CONFIG=(
    "--user=${NGINX_USER_NAME}"
    "--group=${NGINX_GROUP_NAME}"
    "--prefix=${NGINX_INSTALL_FOLDER}"
    "--sbin-path=${NGINX_INSTALL_FOLDER}/sbin/nginx"
    "--conf-path=${NGINX_INSTALL_FOLDER}/conf/nginx.conf"
    "--pid-path=${NGINX_INSTALL_FOLDER}/logs/nginx.pid"
    "--error-log-path=${NGINX_INSTALL_FOLDER}/logs/error.log"
    "--http-log-path=${NGINX_INSTALL_FOLDER}/logs/access.log"
    '--with-http_ssl_module'
    '--with-pcre-jit'
    '--with-poll_module'
)