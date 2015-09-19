#!/bin/bash -e

function installDependencies()
{
    installAptGetPackages 'build-essential'
}

function install()
{
    # Install

    local -r tempISOFilePath="$(getTemporaryFile)"
    local -r tempMountFolderPath="$(getTemporaryFolder)"

    downloadFile "${VBOX_GUEST_ADDITIONS_DOWNLOAD_URL}" "${tempISOFilePath}" true
    mount -o loop "#{tempISOFilePath}" "${tempMountFolderPath}"
    yes | "${tempMountFolderPath}/VBoxLinuxAdditions.run"

    # Clean Up

    umount "${tempMountFolderPath}"
    rm -f -r "${tempISOFilePath}" "${tempMountFolderPath}"

    # Check Service Status

    service vboxadd status
    service vboxadd-service status
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING VBOX-GUEST-ADDITIONS'

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"