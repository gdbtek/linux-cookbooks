#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installPortableBinary \
        'CHEF-INFRA-CLIENT' \
        "${CHEF_INFRA_CLIENT_DOWNLOAD_URL}" \
        "${CHEF_INFRA_CLIENT_INSTALL_FOLDER_PATH}" \
        'bin/chef-apply, bin/chef-client, bin/chef-shell, bin/chef-solo, bin/knife, bin/ohai' \
        '-v' \
        'true'
}

main "${@}"