#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING CQLSH'

    checkRequireLinuxSystem
    checkRequireRootUser

    umask '0022'
    initializeFolder "${CQLSH_INSTALL_FOLDER_PATH}"
    unzipRemoteFile "${CQLSH_DOWNLOAD_URL}" "${CQLSH_INSTALL_FOLDER_PATH}"
    rm -f '/usr/bin/cqlsh'
    ln -f -s "${CQLSH_INSTALL_FOLDER_PATH}/bin/cqlsh" '/usr/bin/cqlsh'
}

main "${@}"