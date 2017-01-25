#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${TERRAFORM_INSTALL_FOLDER_PATH}"
    initializeFolder "${TERRAFORM_INSTALL_FOLDER_PATH}/bin"

    # Install

    unzipRemoteFile "${TERRAFORM_DOWNLOAD_URL}" "${TERRAFORM_INSTALL_FOLDER_PATH}/bin"
    chown -R "$(whoami):$(whoami)" "${TERRAFORM_INSTALL_FOLDER_PATH}"
    ln -f -s "${TERRAFORM_INSTALL_FOLDER_PATH}/bin/terraform" '/usr/local/bin/terraform'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER_PATH__' "${TERRAFORM_INSTALL_FOLDER_PATH}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/terraform.sh.profile" '/etc/profile.d/terraform.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${TERRAFORM_INSTALL_FOLDER_PATH}/bin/terraform" version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING TERRAFORM'

    install
    installCleanUp
}

main "${@}"