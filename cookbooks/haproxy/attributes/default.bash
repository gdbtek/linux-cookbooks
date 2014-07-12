#!/bin/bash

haproxyDownloadURL='http://www.haproxy.org/download/1.5/src/haproxy-1.5.1.tar.gz'

haproxyInstallFolder='/opt/haproxy'

haproxyServiceName='haproxy'

haproxyUID='haproxy'
haproxyGID='haproxy'

haproxyPort=80

haproxy_CPU='native'
haproxy_TARGET='custom'

haproxy_USE_ACCEPT4=1
haproxy_USE_CPU_AFFINITY=1
haproxy_USE_CRYPT_H=1
haproxy_USE_CTTPROXY=1
haproxy_USE_DLMALLOC=1
haproxy_USE_EPOLL=1
haproxy_USE_FUTEX=1
haproxy_USE_GETADDRINFO=1
haproxy_USE_GETSOCKNAME=1
haproxy_USE_KQUEUE=1
haproxy_USE_LIBCRYPT=1
haproxy_USE_LINUX_SPLICE=1
haproxy_USE_LINUX_TPROXY=1
haproxy_USE_MY_ACCEPT4=1
haproxy_USE_MY_EPOLL=1
haproxy_USE_MY_SPLICE=1
haproxy_USE_NETFILTER=1
haproxy_USE_OPENSSL=1
haproxy_USE_PCRE=1
haproxy_USE_PCRE_JIT=1
haproxy_USE_POLL=1
haproxy_USE_PRIVATE_CACHE=1
haproxy_USE_PTHREAD_PSHARED=1
haproxy_USE_REGPARM=1
haproxy_USE_STATIC_PCRE=1
haproxy_USE_TFO=1
haproxy_USE_TPROXY=1
haproxy_USE_VSYSCALL=1
haproxy_USE_ZLIB=1