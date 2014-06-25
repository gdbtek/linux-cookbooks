#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${packerInstallFolder}"
    mkdir -p "${packerInstallFolder}"

    # Install

    unzipRemoteFile "${packerDownloadURL}" "${packerInstallFolder}"
    
    chown -R "$(whoami)":"$(whoami)" "${packerInstallFolder}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${packerInstallFolder}")

    createFileFromTemplate "${appPath}/../files/profile/packer.sh" '/etc/profile.d/packer.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${packerInstallFolder}/bin/packer" --version)"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING PACKER'

    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"