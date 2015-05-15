#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local command="sudo stop selenium-server-hub &&
                   cd /tmp &&
                   sudo rm -f -r ubuntu-cookbooks &&
                   sudo git clone https://github.com/gdbtek/ubuntu-cookbooks.git &&
                   sudo /tmp/ubuntu-cookbooks/cookbooks/selenium-server/recipes/install-hub.bash
                   sudo rm -f -r /tmp/ubuntu-cookbooks"

    "${appPath}/../../../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${appPath}/../attributes/selenium.bash" \
        --command "${command}" \
        --machine-type 'master'
}

main "${@}"