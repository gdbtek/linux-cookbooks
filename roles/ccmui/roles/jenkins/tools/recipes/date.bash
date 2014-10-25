#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"
    local command='date'

    "${appPath}/../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${appPath}/../attributes/jenkins.bash" \
        --command "${command}" \
        --machine-type 'master-slave'
}

main "${@}"
