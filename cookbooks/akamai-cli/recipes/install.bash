#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${AKAMAI_INSTALL_FOLDER_PATH}"
    initializeFolder "${AKAMAI_INSTALL_FOLDER_PATH}/bin"

    # Install

    downloadFile "${AKAMAI_DOWNLOAD_URL}" "${AKAMAI_INSTALL_FOLDER_PATH}/bin/akamai" 'true'
    chown -R "$(whoami):$(whoami)" "${AKAMAI_INSTALL_FOLDER_PATH}"
    chmod 755 "${AKAMAI_INSTALL_FOLDER_PATH}/bin/akamai"
    ln -s -f "${AKAMAI_INSTALL_FOLDER_PATH}/bin/akamai" '/usr/bin/akamai'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${AKAMAI_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/akamai.sh.profile" '/etc/profile.d/akamai.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${AKAMAI_INSTALL_FOLDER_PATH}/bin/akamai" --version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING AKAMAI-CLI'

    install
    installCleanUp
}

main "${@}"