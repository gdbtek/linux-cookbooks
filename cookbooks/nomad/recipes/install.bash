#!/bin/bash -e

function install()
{
    umask '0022'

    # Clean Up

    initializeFolder "${NOMAD_INSTALL_FOLDER}"
    initializeFolder "${NOMAD_INSTALL_FOLDER}/bin"

    # Install

    unzipRemoteFile "${NOMAD_DOWNLOAD_URL}" "${NOMAD_INSTALL_FOLDER}/bin"
    chown -R "$(whoami):$(whoami)" "${NOMAD_INSTALL_FOLDER}"
    ln -f -s "${NOMAD_INSTALL_FOLDER}/bin/nomad" '/usr/local/bin/nomad'

    # Config Profile

    local -r profileConfigData=('__INSTALL_FOLDER__' "${NOMAD_INSTALL_FOLDER}")

    createFileFromTemplate "${APP_FOLDER_PATH}/../templates/nomad.sh.profile" '/etc/profile.d/nomad.sh' "${profileConfigData[@]}"

    # Display Version

    displayVersion "$("${NOMAD_INSTALL_FOLDER}/bin/nomad" version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING NOMAD'

    install
    installCleanUp
}

main "${@}"