#!/bin/bash

function install()
{
    # Clean Up

    rm -rf "${packerInstallFolder}"
    mkdir -p "${packerInstallFolder}/bin"

    # Install

    unzipRemoteFile "${packerDownloadURL}" "${packerInstallFolder}/bin"
    chown -R "$(whoami)":"$(whoami)" "${packerInstallFolder}"

    # Config Profile

    local profileConfigData=('__INSTALL_FOLDER__' "${packerInstallFolder}")

    createFileFromTemplate "${appPath}/../templates/default/packer.sh.profile" '/etc/profile.d/packer.sh' "${profileConfigData[@]}"

    # Display Version

    info "\n$("${packerInstallFolder}/bin/packer" --version)"
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING PACKER'

    install
    installCleanUp
}

main "${@}"