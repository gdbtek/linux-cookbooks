#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installPortableBinary \
        'CONSUL' \
        "${CONSUL_DOWNLOAD_URL}" \
        "${CONSUL_INSTALL_FOLDER_PATH}" \
        'consul' \
        'version' \
        'true'
}

main "${@}"