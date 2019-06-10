#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installPortableBinary 'AKAMAI-CLI' "${AKAMAI_CLI_DOWNLOAD_URL}" "${AKAMAI_CLI_INSTALL_FOLDER_PATH}" 'akamai' '--version'
}

main "${@}"