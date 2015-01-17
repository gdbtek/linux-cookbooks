#!/bin/bash -e

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local command="cd /tmp &&
                   sudo rm -f -r ubuntu-cookbooks &&
                   sudo git clone https://github.com/gdbtek/ubuntu-cookbooks.git &&
                   sudo /tmp/ubuntu-cookbooks/cookbooks/jdk/recipes/install.bash
                   sudo rm -f -r /tmp/ubuntu-cookbooks"

    "${appPath}/../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${appPath}/../attributes/jenkins.bash" \
        --command "${command}" \
        --machine-type 'master-slave'
}

main "${@}"
