#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../pcre/attributes/default.bash"

export NGINX_DOWNLOAD_URL='http://nginx.org/download/nginx-1.15.8.tar.gz'
export NGINX_PCRE_DOWNLOAD_URL="${PCRE_DOWNLOAD_URL}"
export NGINX_ZLIB_DOWNLOAD_URL='http://zlib.net/zlib-1.2.11.tar.gz'

export NGINX_INSTALL_FOLDER_PATH='/opt/nginx'

export NGINX_SERVICE_NAME='nginx'

export NGINX_USER_NAME='nginx'
export NGINX_GROUP_NAME='nginx'

export NGINX_PORT='80'

export NGINX_CONFIG=(
    "--user=${NGINX_USER_NAME}"
    "--group=${NGINX_GROUP_NAME}"
    "--prefix=${NGINX_INSTALL_FOLDER_PATH}"
    "--sbin-path=${NGINX_INSTALL_FOLDER_PATH}/sbin/nginx"
    "--conf-path=${NGINX_INSTALL_FOLDER_PATH}/conf/nginx.conf"
    "--pid-path=${NGINX_INSTALL_FOLDER_PATH}/logs/nginx.pid"
    "--error-log-path=${NGINX_INSTALL_FOLDER_PATH}/logs/error.log"
    "--http-log-path=${NGINX_INSTALL_FOLDER_PATH}/logs/access.log"
    '--with-http_ssl_module'
    '--with-pcre-jit'
    '--with-poll_module'
)