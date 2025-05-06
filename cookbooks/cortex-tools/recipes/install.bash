#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installPortableBinary \
        'CORTEX-TOOLS' \
        "${CORTEX_TOOLS_DOWNLOAD_URL}" \
        "${CORTEX_TOOLS_INSTALL_FOLDER_PATH}" \
        'cortex-tools' \
        'version' \
        'true'
}

main "${@}"