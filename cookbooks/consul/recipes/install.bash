#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${CONSUL_INSTALL_FOLDER}"
    initializeFolder "${CONSUL_INSTALL_FOLDER}/bin"

    # Install

    unzipRemoteFile "${CONSUL_DOWNLOAD_URL}" "${CONSUL_INSTALL_FOLDER}/bin"
    chown -R "$(whoami):$(whoami)" "${CONSUL_INSTALL_FOLDER}"
    ln -f -s "${CONSUL_INSTALL_FOLDER}/bin/consul" '/usr/local/bin/consul'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${CONSUL_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/consul.sh.profile" '/etc/profile.d/consul.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${CONSUL_INSTALL_FOLDER}/bin/consul" version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING CONSUL'

    install
    installCleanUp
}

main "${@}"