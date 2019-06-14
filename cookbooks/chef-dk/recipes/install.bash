#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installPortableBinary 'CHEF-DK' "${CHEF_DK_DOWNLOAD_URL}" "${CHEF_DK_INSTALL_FOLDER_PATH}" 'bin/knife' '-v' 'false'
}

main "${@}"