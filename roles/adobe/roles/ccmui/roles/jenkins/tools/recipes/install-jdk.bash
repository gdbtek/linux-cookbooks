#!/bin/bash -e

function main()
{
    local -r attributeFile="${1}"

    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r command="cd /var/tmp &&
                      sudo rm -f -r ubuntu-cookbooks &&
                      sudo git clone --depth=1 https://github.com/gdbtek/ubuntu-cookbooks.git &&
                      sudo /var/tmp/ubuntu-cookbooks/cookbooks/jdk/recipes/install.bash
                      sudo rm -f -r /var/tmp/ubuntu-cookbooks"

    "${appFolderPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${attributeFile}" \
        --command "${command}" \
        --machine-type 'masters-slaves'
}

main "${@}"