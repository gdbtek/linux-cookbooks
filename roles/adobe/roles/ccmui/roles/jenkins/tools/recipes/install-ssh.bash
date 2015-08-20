#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r command="cd /tmp &&
                      sudo rm -f -r ubuntu-cookbooks &&
                      sudo git clone https://github.com/gdbtek/ubuntu-cookbooks.git &&
                      sudo /tmp/ubuntu-cookbooks/cookbooks/ssh/recipes/install.bash
                      sudo rm -f -r /tmp/ubuntu-cookbooks"

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'masters-slaves'
}

main "${@}"