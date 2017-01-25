#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${JQ_INSTALL_FOLDER_PATH}"
    initializeFolder "${JQ_INSTALL_FOLDER_PATH}/bin"

    # Install

    downloadFile "${JQ_DOWNLOAD_URL}" "${JQ_INSTALL_FOLDER_PATH}/bin/jq" 'true'
    chown -R "$(whoami):$(whoami)" "${JQ_INSTALL_FOLDER_PATH}"
    chmod 755 "${JQ_INSTALL_FOLDER_PATH}/bin/jq"
    symlinkLocalBin "${JQ_INSTALL_FOLDER_PATH}/bin"

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${JQ_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/jq.sh.profile" '/etc/profile.d/jq.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${JQ_INSTALL_FOLDER_PATH}/bin/jq" --version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING JQ'

    install
    installCleanUp
}

main "${@}"