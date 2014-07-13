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
    '--with-http_ssl_module'
    '--with-pcre-jit'
    '--with-poll_module'
)