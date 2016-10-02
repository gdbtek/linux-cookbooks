#!/bin/bash -e

function installDependencies()
{
    installBuildEssential
}

function install()
{
    # Install

    local -r tempISOFilePath="$(getTemporaryFile)"
    local -r tempMountFolderPath="$(getTemporaryFolder)"

    downloadFile "${VBOX_GUEST_ADDITIONS_DOWNLOAD_URL}" "${tempISOFilePath}" true
    mount -o loop "${tempISOFilePath}" "${tempMountFolderPath}"
    yes | sh "${tempMountFolderPath}/VBoxLinuxAdditions.run" || true

    # Clean Up

    umount -v "${tempMountFolderPath}"
    rm -f -r -v "${tempISOFilePath}" "${tempMountFolderPath}"

    # Config Init

    createInitFileFromTemplate 'vbox-guest-additions' "${APP_FOLDER_PATH}/../files"

    # Check Service Status

    service vboxadd status
    service vboxadd-service status
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING VBOX-GUEST-ADDITIONS'

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"