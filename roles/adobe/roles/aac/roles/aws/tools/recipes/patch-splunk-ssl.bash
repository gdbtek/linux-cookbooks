#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r command="sudo chef-client -o \"recipe[splunkforwarder]\" &&
                      sudo tail -2 '/opt/splunkforwarder/etc/auth/adobe_certs/indexer_root.crt' &&
                      sudo tail -2 '/opt/splunkforwarder/etc/auth/adobe_certs/indexer_ssl.crt'"

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'masters'
}

main "${@}"