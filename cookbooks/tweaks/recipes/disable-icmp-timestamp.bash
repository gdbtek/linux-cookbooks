#!/bin/bash -e

function install()
{
    umask '0022'

    iptables -A INPUT -p ICMP --icmp-type timestamp-request -j DROP
    iptables -A INPUT -p ICMP --icmp-type timestamp-reply -j DROP
    iptables-save

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'DISABLING ICMP-TIMESTAMP'

    install
    installCleanUp
}

main "${@}"