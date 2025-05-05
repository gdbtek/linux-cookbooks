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
    curl -L "${ZDM_UTIL_DOWNLOAD_URL}" --retry 12 --retry-delay 5 | tar -C "${ZDM_UTIL_INSTALL_FOLDER_PATH}" -x -z
    mv ${ZDM_UTIL_INSTALL_FOLDER_PATH}/zdm-util-v* "${ZDM_UTIL_INSTALL_FOLDER_PATH}/zdm-util"
    rm -f -r '/usr/bin/zdm-util'
    ln -f -s "${ZDM_UTIL_INSTALL_FOLDER_PATH}/zdm-util" '/usr/bin/zdm-util'
}

main "${@}"