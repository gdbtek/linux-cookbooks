#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${PACKER_INSTALL_FOLDER}"
    mkdir -p "${PACKER_INSTALL_FOLDER}/bin"

    # Install

    unzipRemoteFile "${PACKER_DOWNLOAD_URL}" "${PACKER_INSTALL_FOLDER}/bin"
    chown -R "$(whoami):$(whoami)" "${PACKER_INSTALL_FOLDER}"
    symlinkLocalBin "${PACKER_INSTALL_FOLDER}/bin"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${PACKER_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/packer.sh.profile" '/etc/profile.d/packer.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${PACKER_INSTALL_FOLDER}/bin/packer" version)"
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING PACKER'

    install
    installCleanUp
}

main "${@}"