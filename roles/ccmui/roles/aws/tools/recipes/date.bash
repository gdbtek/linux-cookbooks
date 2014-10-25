#!/bin/bash -e

function main()
{
    local attributeFile="${1}"

    local appPath="$(cd "$(dirname "${0}")" && pwd)"
    local command='date'

    "${appPath}/../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'slave'
}

main "${@}"
