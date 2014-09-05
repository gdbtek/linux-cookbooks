#!/bin/bash -e

function install()
{
    # Clean Up

    initializeFolder "${packerInstallFolder}"
    mkdir -p "${packerInstallFolder}/bin"

    # Install

    unzipRemoteFile "${packerDownloadURL}" "${packerInstallFolder}/bin"
    chown -R "$(whoami):$(whoami)" "${packerInstallFolder}"
    symlinkLocalBin "${packerInstallFolder}/bin"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${packerInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/packer.sh.profile" '/etc/profile.d/packer.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${packerInstallFolder}/bin/packer" --version)"
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING PACKER'

    install
    installCleanUp
}

main "${@}"