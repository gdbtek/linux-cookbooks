#!/bin/bash -e

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local -r command="sudo stop selenium-server-hub &&
                      cd /var/tmp &&
                      sudo rm -f -r ubuntu-cookbooks &&
                      sudo git clone --depth=1 https://github.com/gdbtek/ubuntu-cookbooks.git &&
                      sudo /var/tmp/ubuntu-cookbooks/cookbooks/selenium-server/recipes/install-hub.bash
                      sudo rm -f -r /var/tmp/ubuntu-cookbooks"

    "${appFolderPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${appFolderPath}/../attributes/default.bash" \
        --command "${command}" \
        --machine-type 'masters'
}

main "${@}"