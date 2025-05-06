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
    chown -R 'ubuntu:ubuntu' "${ZDM_PROXY_AUTOMATION_INSTALL_FOLDER_PATH}"
    ls -la "${ZDM_PROXY_AUTOMATION_INSTALL_FOLDER_PATH}"
    umask '0077'
}

main "${@}"