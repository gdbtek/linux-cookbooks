#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installPortableBinary 'CHEF-INFRA-CLIENT' "${CHEF_INFRA_CLIENT_DOWNLOAD_URL}" "${CHEF_INFRA_CLIENT_INSTALL_FOLDER_PATH}" 'bin/knife' '-v' 'true'
}

main "${@}"