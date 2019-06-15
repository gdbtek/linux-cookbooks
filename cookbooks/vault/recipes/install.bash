#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installPortableBinary \
        'VAULT' \
        "${VAULT_DOWNLOAD_URL}" \
        "${VAULT_INSTALL_FOLDER_PATH}" \
        'vault' \
        'version' \
        'true'
}

main "${@}"