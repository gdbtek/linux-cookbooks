#!/bin/bash -e

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r command='date'

    "${appFolderPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${appFolderPath}/../attributes/default.bash" \
        --command "${command}" \
        --machine-type 'masters'
}

main "${@}"