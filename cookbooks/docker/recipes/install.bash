#!/bin/bash -e

function install()
{
    umask '0022'

    # Download and Install

    checkExistURL "${DOCKER_DOWNLOAD_URL}"
    debug "\nDownloading '${DOCKER_DOWNLOAD_URL}'\n"
    curl -L "${DOCKER_DOWNLOAD_URL}" --retry 12 --retry-delay 5 | bash -e

    # Config Grub

    header 'UPDATING GRUB CONFIG'

    local -r grubConfigFile='/etc/default/grub'
    local -r grubConfigAttribute='GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"'

    createFileFromTemplate "${grubConfigFile}" "${grubConfigFile}" 'GRUB_CMDLINE_LINUX=""' "${grubConfigAttribute}"
    appendToFileIfNotFound "${grubConfigFile}" "$(stringToSearchPattern "${grubConfigAttribute}")" "${grubConfigAttribute}" 'true' 'false' 'true'

    update-grub

    # Display Status

    statusService 'docker'

    # Display Info

    header 'DISPLAYING DOCKER INFO'
    info "\n$(docker info)"

    # Display Version

    displayVersion "$(docker version)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING DOCKER'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"