#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installPortableBinary 'TERRAFORM' "${TERRAFORM_DOWNLOAD_URL}" "${TERRAFORM_INSTALL_FOLDER_PATH}" 'terraform' 'version'
}

main "${@}"