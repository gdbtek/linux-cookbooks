#!/bin/bash -e

function install()
{
    umask '0022'

    appendToFileIfNotFound '/etc/sysctl.conf' 'net.ipv4.icmp_echo_ignore_all = 1' 'net.ipv4.icmp_echo_ignore_all = 1' 'false' 'false' 'true'
    cat '/etc/sysctl.conf'

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    header 'DISABLING ICMP-TIMESTAMP'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"