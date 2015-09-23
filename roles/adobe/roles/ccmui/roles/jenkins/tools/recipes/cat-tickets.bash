#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    local -r command="find / -type f -name 'tickets_*' -exec cat {} \; print"

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'slaves'
}

main "${@}"