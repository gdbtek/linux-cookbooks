#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING ZDM-UTIL'

    checkRequireLinuxSystem
    checkRequireRootUser

    umask '0022'
    initializeFolder "${ZDM_UTIL_INSTALL_FOLDER_PATH}"
    unzipRemoteFile "${ZDM_UTIL_DOWNLOAD_URL}" "${ZDM_UTIL_INSTALL_FOLDER_PATH}" 'tgz'
}

main "${@}"