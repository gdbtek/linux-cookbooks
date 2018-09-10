#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../libraries/util.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'FLUSHING FIREWALL'

    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT

    iptables -t nat -F
    iptables -t mangle -F
    iptables -F
    iptables -X
}

main "${@}"