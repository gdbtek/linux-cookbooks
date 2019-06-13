#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installPortableBinary 'JQ' "${JQ_DOWNLOAD_URL}" "${JQ_INSTALL_FOLDER_PATH}" 'jq' '--version' 'true'
}

main "${@}"