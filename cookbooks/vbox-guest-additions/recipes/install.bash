#!/bin/bash -e

function installDependencies()
{
    installBuildEssential
}

function install()
{
    umask '0022'

    # Download

    local -r tempISOFilePath="$(getTemporaryFile)"
    local -r tempMountFolderPath="$(getTemporaryFolder)"
    local -r tempInstallerFolderPath="$(getTemporaryFolder)"

    downloadFile "${VBOX_GUEST_ADDITIONS_DOWNLOAD_URL}" "${tempISOFilePath}" true
    mount -o loop "${tempISOFilePath}" "${tempMountFolderPath}"
    copyFolderContent "${tempMountFolderPath}" "${tempInstallerFolderPath}"
    umount -v "${tempMountFolderPath}"
    rm -f -r "${tempISOFilePath}" "${tempMountFolderPath}"

    # Install

    "${tempInstallerFolderPath}/VBoxLinuxAdditions.run" || true
    rm -f -r "${tempInstallerFolderPath}"

    # Config Init

    createInitFileFromTemplate 'vbox-guest-additions' "$(dirname "${BASH_SOURCE[0]}")/../files"

    # Check Service Status

    service vboxadd status
    service vboxadd-service status

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING VBOX-GUEST-ADDITIONS'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"