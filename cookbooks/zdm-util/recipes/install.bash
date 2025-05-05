#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installPortableBinary \
        'ZDM-UTIL' \
        "${ZDM_UTIL_DOWNLOAD_URL}" \
        "${ZDM_UTIL_INSTALL_FOLDER_PATH}" \
        'zdm-util' \
        'version' \
        'true'
}

main "${@}"