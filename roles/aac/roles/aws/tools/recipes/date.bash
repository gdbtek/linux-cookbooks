#!/bin/bash -e

function main()
{
    local attributeFile="${1}"

    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local command='date'

    "${appPath}/../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'slave'
}

main "${@}"