#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r command='sudo chown syslog:adm /var/log/ccm/ccm-web.log &&
                      ls -la /var/log/ccm/ccm-web.log'

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'masters'
}

main "${@}"