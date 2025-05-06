#!/bin/bash -e

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING ZDM-PROXY-AUTOMATION'

    checkRequireLinuxSystem
    checkRequireRootUser

    umask '0022'
    initializeFolder "${ZDM_PROXY_AUTOMATION_INSTALL_FOLDER_PATH}"
    unzipRemoteFile "${ZDM_PROXY_AUTOMATION_DOWNLOAD_URL}" "${ZDM_PROXY_AUTOMATION_INSTALL_FOLDER_PATH}"
    # mv ${ZDM_PROXY_AUTOMATION_INSTALL_FOLDER_PATH}/zdm-util-v* "${ZDM_PROXY_AUTOMATION_INSTALL_FOLDER_PATH}/zdm-util"
    # rm -f '/usr/bin/zdm-util'
    # ln -f -s "${ZDM_PROXY_AUTOMATION_INSTALL_FOLDER_PATH}/zdm-util" '/usr/bin/zdm-util'
    umask '0077'
}

main "${@}"