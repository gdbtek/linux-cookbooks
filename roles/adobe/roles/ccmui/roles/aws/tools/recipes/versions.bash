#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r command="java -version &&
                      echo &&
                      node --version"

    "${appFolderPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'masters'
}

main "${@}"