#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r command="find '/var/log' -type f \( -regex '.*\.[0-9]+' -o -regex '.*\.[0-9]+.gz' \) -delete -print &&
                      echo &&
                      find '/var/log' -type f -exec cp -f '/dev/null' {} \; -print"

    "${appFolderPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'masters-slaves'
}

main "${@}"