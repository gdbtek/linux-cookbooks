#!/bin/bash

function installDependencies()
{
    runAptGetUpdate

    installAptGetPackage 'build-essential'
    installAptGetPackage 'libpcre3-dev'
    installAptGetPackage 'libssl-dev'
}

function install()
{
    # Clean Up

    rm -rf "${haproxyInstallFolder}"
    mkdir -p "${haproxyInstallFolder}"

    # Install

    local currentPath="$(pwd)"
    local tempFolder="$(getTemporaryFolder)"

    unzipRemoteFile "${haproxyDownloadURL}" "${tempFolder}"
    cd "${tempFolder}" &&
    make \
        CPU="${haproxy_CPU}" \
        TARGET="${haproxy_TARGET}" \
        PCREDIR="${haproxy_PCREDIR}" \
        PCRE_LIB="${haproxy_PCRE_LIB}" \
        PCRE_INC="${haproxy_PCRE_INC}" \
        USE_ACCEPT4="${haproxy_USE_ACCEPT4}" \
        USE_CPU_AFFINITY="${haproxy_USE_CPU_AFFINITY}" \
        USE_CRYPT_H="${haproxy_USE_CRYPT_H}" \
        USE_CTTPROXY="${haproxy_USE_CTTPROXY}" \
        USE_DLMALLOC="${haproxy_USE_DLMALLOC}" \
        USE_EPOLL="${haproxy_USE_EPOLL}" \
        USE_FUTEX="${haproxy_USE_FUTEX}" \
        USE_GETADDRINFO="${haproxy_USE_GETADDRINFO}" \
        USE_GETSOCKNAME="${haproxy_USE_GETSOCKNAME}" \
        USE_KQUEUE="${haproxy_USE_KQUEUE}" \
        USE_LIBCRYPT="${haproxy_USE_LIBCRYPT}" \
        USE_LINUX_SPLICE="${haproxy_USE_LINUX_SPLICE}" \
        USE_LINUX_TPROXY="${haproxy_USE_LINUX_TPROXY}" \
        USE_MY_ACCEPT4="${haproxy_USE_MY_ACCEPT4}" \
        USE_MY_EPOLL="${haproxy_USE_MY_EPOLL}" \
        USE_MY_SPLICE="${haproxy_USE_MY_SPLICE}" \
        USE_NETFILTER="${haproxy_USE_NETFILTER}" \
        USE_OPENSSL="${haproxy_USE_OPENSSL}" \
        USE_PCRE="${haproxy_USE_PCRE}" \
        USE_PCRE_JIT="${haproxy_USE_PCRE_JIT}" \
        USE_POLL="${haproxy_USE_POLL}" \
        USE_PRIVATE_CACHE="${haproxy_USE_PRIVATE_CACHE}" \
        USE_PTHREAD_PSHARED="${haproxy_USE_PTHREAD_PSHARED}" \
        USE_REGPARM="${haproxy_USE_REGPARM}" \
        USE_STATIC_PCRE="${haproxy_USE_STATIC_PCRE}" \
        USE_TFO="${haproxy_USE_TFO}" \
        USE_TPROXY="${haproxy_USE_TPROXY}" \
        USE_VSYSCALL="${haproxy_USE_VSYSCALL}" \
        USE_ZLIB="${haproxy_USE_ZLIB}" &&
    make install \
        PREFIX='' \
        DESTDIR="${haproxyInstallFolder}"

    rm -rf "${tempFolder}"
    cd "${currentPath}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${haproxyInstallFolder}")

    createFileFromTemplate "${appPath}/../files/profile/haproxy.sh" '/etc/profile.d/haproxy.sh' "${profileConfigData[@]}"

    # Config Upstart

    local upstartConfigData=('__INSTALL_FOLDER__' "${haproxyInstallFolder}")

    createFileFromTemplate "${appPath}/../files/upstart/haproxy.conf" "/etc/init/${haproxyServiceName}.conf" "${upstartConfigData[@]}"

    # Start

    addSystemUser "${haproxyUID}" "${haproxyGID}"
    chown -R "${haproxyUID}":"${haproxyGID}" "${haproxyInstallFolder}"
    start "${haproxyServiceName}"

    # Display Version

    info "\n$("${haproxyInstallFolder}/sbin/haproxy" -vv 2>&1)"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING HAPROXY'

    checkRequireRootUser
    checkRequirePort "${haproxyPort}"

    installDependencies
    install
    installCleanUp

    displayOpenPorts
}

main "${@}"