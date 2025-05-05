#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installPortableBinary \
        'CONSUL' \
        "${ZDM_PROXY_DOWNLOAD_URL}" \
        "${ZDM_PROXY_INSTALL_FOLDER_PATH}" \
        'consul' \
        'version' \
        'true'
}

main "${@}"