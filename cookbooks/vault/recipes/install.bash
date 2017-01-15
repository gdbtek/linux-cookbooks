#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${VAULT_INSTALL_FOLDER}"
    initializeFolder "${VAULT_INSTALL_FOLDER}/bin"

    # Install

    unzipRemoteFile "${VAULT_DOWNLOAD_URL}" "${VAULT_INSTALL_FOLDER}/bin"
    chown -R "$(whoami):$(whoami)" "${VAULT_INSTALL_FOLDER}"
    ln -f -s "${VAULT_INSTALL_FOLDER}/bin/vault" '/usr/local/bin/vault'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${VAULT_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/vault.sh.profile" '/etc/profile.d/vault.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${VAULT_INSTALL_FOLDER}/bin/vault" version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING VAULT'

    install
    installCleanUp
}

main "${@}"