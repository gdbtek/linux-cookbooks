#!/bin/bash -e

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../attributes/default.bash"

    local -r command="cd /tmp &&
                      sudo rm -f -r ubuntu-cookbooks &&
                      sudo git clone https://github.com/gdbtek/ubuntu-cookbooks.git &&
                      sudo /tmp/ubuntu-cookbooks/cookbooks/node-js/recipes/install.bash '${NAMNGUYE_NODE_JS_VERSION}' '${NAMNGUYE_NODE_JS_INSTALL_FOLDER}'
                      sudo rm -f -r /tmp/ubuntu-cookbooks"

    "${appPath}/../../../../../../tools/run-remote-command.bash" \
        --attribute-file "${appPath}/../attributes/default.bash" \
        --command "${command}" \
        --machine-type 'masters'
}

main "${@}"