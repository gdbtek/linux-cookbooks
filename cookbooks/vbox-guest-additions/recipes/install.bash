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
    mount -o loop "${tempISOFilePath}" "${tempMountFolderPath}"
    yes | "${tempMountFolderPath}/VBoxLinuxAdditions.run" || true

    # Clean Up

    umount -v "${tempMountFolderPath}"
    rm -f -r -v "${tempISOFilePath}" "${tempMountFolderPath}"

    # Config Upstart

    cp "${appFolderPath}/../files/vbox-guest-additions.conf.upstart" '/etc/init/vbox-guest-additions.conf'

    # Check Service Status

    service vboxadd status
    service vboxadd-service status
}

function main()
{
    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING VBOX-GUEST-ADDITIONS'

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"