#!/bin/bash -e

nginxDownloadURL='http://nginx.org/download/nginx-1.6.2.tar.gz'
nginxPCREDownloadURL='ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.36.tar.gz'
nginxZLIBDownloadURL='http://zlib.net/zlib-1.2.8.tar.gz'

nginxInstallFolder='/opt/nginx'

nginxServiceName='nginx'

nginxUserName='nginx'
nginxGroupName='nginx'

nginxPort=80

nginxConfig=(
    "--user=${nginxUserName}"
    "--group=${nginxGroupName}"
    "--prefix=${nginxInstallFolder}"
    "--sbin-path=${nginxInstallFolder}/sbin/nginx"
    "--conf-path=${nginxInstallFolder}/conf/nginx.conf"
    "--pid-path=${nginxInstallFolder}/logs/nginx.pid"
    "--error-log-path=${nginxInstallFolder}/logs/error.log"
    "--http-log-path=${nginxInstallFolder}/logs/access.log"
    '--with-http_ssl_module'
    '--with-pcre-jit'
    '--with-poll_module'
)