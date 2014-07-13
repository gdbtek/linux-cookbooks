#!/bin/bash

source "$(dirname "${0}")/../../pcre/attributes/default.bash" || exit 1

nginxDownloadURL='http://nginx.org/download/nginx-1.7.3.tar.gz'
nginxZLIBDownloadURL='http://zlib.net/zlib-1.2.8.tar.gz'

nginxInstallFolder='/opt/nginx'

nginxServiceName='nginx'

nginxUID='nginx'
nginxGID='nginx'

nginxPort=80

nginxConfig=(
    "--user='${nginxUID}'"
    "--group='${nginxGID}'"
    "--prefix='${nginxInstallFolder}'"
    "--sbin-path='${nginxInstallFolder}/sbin'"
    "--conf-path='${nginxInstallFolder}/conf/nginx.conf'"
    "--pid-path='${nginxInstallFolder}/logs/nginx.pid'"
    "--error-log-path='${nginxInstallFolder}/logs/error.log'"
    "--http-log-path='${nginxInstallFolder}/logs/access.log'"
    '--with-http_ssl_module'
    '--with-pcre-jit'
    '--with-poll_module'
)