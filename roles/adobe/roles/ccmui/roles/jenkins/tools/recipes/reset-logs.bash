#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r command="find '/var/log' -type f \( -regex '.*\.[0-9]+' -o -regex '.*\.[0-9]+.gz' \) -delete -print &&
                      find '/var/log' -type f -exec cp -f '/dev/null' {} \; -print"

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'masters-slaves'
}

main "${@}"