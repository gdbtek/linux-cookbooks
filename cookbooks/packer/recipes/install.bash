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

    createFileFromTemplate "${appPath}/../templates/default/packer.sh.profile" '/etc/profile.d/packer.sh' "${profileConfigData[@]}"

    # Display Version

    info "$("${PACKER_INSTALL_FOLDER}/bin/packer" version)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING PACKER'

    install
    installCleanUp
}

main "${@}"