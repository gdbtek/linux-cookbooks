#!/bin/bash -e

export nginxDownloadURL='http://nginx.org/download/nginx-1.7.10.tar.gz'
export nginxPCREDownloadURL='ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.36.tar.gz'
export nginxZLIBDownloadURL='http://zlib.net/zlib-1.2.8.tar.gz'

export nginxInstallFolder='/opt/nginx'

export nginxServiceName='nginx'

export nginxUserName='nginx'
export nginxGroupName='nginx'

export nginxPort='80'

export nginxConfig=(
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