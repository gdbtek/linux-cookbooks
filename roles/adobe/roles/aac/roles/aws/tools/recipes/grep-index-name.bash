#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r command='sudo grep -F "index = " "/opt/splunkforwarder/etc/system/local/inputs.conf"'

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'slaves'
}

main "${@}"