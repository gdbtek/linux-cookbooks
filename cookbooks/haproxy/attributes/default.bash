#!/bin/bash

source "$(dirname "${0}")/../../pcre/attributes/default.bash" || exit 1

haproxyDownloadURL='http://www.haproxy.org/download/1.5/src/haproxy-1.5.2.tar.gz'

haproxyInstallFolder='/opt/haproxy'

haproxyServiceName='haproxy'

haproxyUID='haproxy'
haproxyGID='haproxy'

haproxyPort=80

haproxyConfig=(
    'CPU='native''
    'TARGET='custom''
    "PCREDIR='${pcreInstallFolder}'"
    "PCRE_LIB='${pcreInstallFolder}/lib'"
    "PCRE_INC='${pcreInstallFolder}/include'"
    'USE_CPU_AFFINITY=1'
    'USE_CRYPT_H=1'
    'USE_CTTPROXY=1'
    'USE_EPOLL=1'
    'USE_FUTEX=1'
    'USE_GETADDRINFO=1'
    'USE_GETSOCKNAME=1'
    'USE_KQUEUE='''
    'USE_LIBCRYPT=1'
    'USE_LINUX_SPLICE=1'
    'USE_LINUX_TPROXY=1'
    'USE_MY_ACCEPT4=1'
    'USE_MY_EPOLL=1'
    'USE_NETFILTER=1'
    'USE_OPENSSL=1'
    'USE_PCRE=1'
    'USE_PCRE_JIT=1'
    'USE_POLL=1'
    'USE_PRIVATE_CACHE=1'
    'USE_PTHREAD_PSHARED=1'
    'USE_REGPARM=1'
    'USE_STATIC_PCRE=1'
    'USE_TFO=1'
    'USE_TPROXY=1'
    'USE_VSYSCALL=1'
    'USE_ZLIB=1'
)

# haproxy_USE_ACCEPT4=1
# haproxy_USE_DLMALLOC=1
# haproxy_USE_MY_SPLICE=1