#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${PACKER_INSTALL_FOLDER_PATH}"
    initializeFolder "${PACKER_INSTALL_FOLDER_PATH}/bin"

    # Install

    unzipRemoteFile "${PACKER_DOWNLOAD_URL}" "${PACKER_INSTALL_FOLDER_PATH}/bin"
    chown -R "$(whoami):$(whoami)" "${PACKER_INSTALL_FOLDER_PATH}"
    ln -f -s "${PACKER_INSTALL_FOLDER_PATH}/bin/packer" '/usr/local/bin/packer'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${PACKER_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/packer.sh.profile" '/etc/profile.d/packer.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${PACKER_INSTALL_FOLDER_PATH}/bin/packer" version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING PACKER'

    install
    installCleanUp
}

main "${@}"