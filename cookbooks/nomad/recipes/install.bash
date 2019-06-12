#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    installPortableBinary 'NOMAD' "${NOMAD_DOWNLOAD_URL}" "${NOMAD_INSTALL_FOLDER_PATH}" 'nomad' 'version' 'true'
}

main "${@}"