#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${PORTER_INSTALL_FOLDER_PATH}"
    initializeFolder "${PORTER_INSTALL_FOLDER_PATH}/bin"

    # Install

    downloadFile "${PORTER_DOWNLOAD_URL}" "${PORTER_INSTALL_FOLDER_PATH}/bin/porter" 'true'
    chown -R "$(whoami):$(whoami)" "${PORTER_INSTALL_FOLDER_PATH}"
    chmod 755 "${PORTER_INSTALL_FOLDER_PATH}/bin/porter"
    symlinkLocalBin "${PORTER_INSTALL_FOLDER_PATH}/bin"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${PORTER_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/porter.sh.profile" '/etc/profile.d/porter.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${PORTER_INSTALL_FOLDER_PATH}/bin/porter" version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING PORTER'

    install
    installCleanUp
}

main "${@}"