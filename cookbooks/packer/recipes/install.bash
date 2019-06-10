#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installPortableBinary 'PACKER' "${PACKER_DOWNLOAD_URL}" "${PACKER_INSTALL_FOLDER_PATH}" 'packer' 'version'
}

main "${@}"