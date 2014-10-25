#!/bin/bash -e

function main()
{
    local attributeFile="${1}"

    local appPath="$(cd "$(dirname "${0}")" && pwd)"
    local command="java -version &&
                   echo &&
                   node --version"

    "${appPath}/../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'slave'
}

main "${@}"
