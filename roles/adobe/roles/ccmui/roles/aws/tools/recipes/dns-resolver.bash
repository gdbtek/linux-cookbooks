#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r command='grep -o "^CCMUI_DNS_RESOLVER_IP=.*$" "/apps/scripts/ccweb.sh" &&
                      grep -F 'nameserver' "/etc/resolv.conf"'

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'masters'
}

main "${@}"