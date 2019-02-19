#!/bin/bash -e

source "$(dirname "${BASH_SOURCE[0]}")/../../pcre/attributes/default.bash"

export HAPROXY_DOWNLOAD_URL='http://www.haproxy.org/download/1.8/src/haproxy-1.8.19.tar.gz'

export HAPROXY_INSTALL_FOLDER_PATH='/opt/haproxy'

export HAPROXY_SERVICE_NAME='haproxy'

export HAPROXY_USER_NAME='haproxy'
export HAPROXY_GROUP_NAME='haproxy'

export HAPROXY_PORT='80'

export HAPROXY_CONFIG=(
    'CPU=native'
    'TARGET=custom'
    "PCREDIR='${PCRE_INSTALL_FOLDER_PATH}'"
    "PCRE_LIB='${PCRE_INSTALL_FOLDER_PATH}/lib'"
    "PCRE_INC='${PCRE_INSTALL_FOLDER_PATH}/include'"
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