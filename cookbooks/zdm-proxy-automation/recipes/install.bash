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
    curl -L "${ZDM_PROXY_AUTOMATION_DOWNLOAD_URL}" --retry 12 --retry-delay 5 | tar -C "${ZDM_PROXY_AUTOMATION_INSTALL_FOLDER_PATH}" -x -z
    # mv ${ZDM_PROXY_AUTOMATION_INSTALL_FOLDER_PATH}/zdm-util-v* "${ZDM_PROXY_AUTOMATION_INSTALL_FOLDER_PATH}/zdm-util"
    # rm -f '/usr/bin/zdm-util'
    # ln -f -s "${ZDM_PROXY_AUTOMATION_INSTALL_FOLDER_PATH}/zdm-util" '/usr/bin/zdm-util'
    umask '0077'
}

main "${@}"