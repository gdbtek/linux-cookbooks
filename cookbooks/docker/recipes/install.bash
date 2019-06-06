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
    local -r grubConfigData=(
        'GRUB_CMDLINE_LINUX=""' "${grubConfigAttribute}"
        'GRUB_HIDDEN_TIMEOUT=0' ''
    )

    createFileFromTemplate "${grubConfigFile}" "${grubConfigFile}" "${grubConfigData[@]}"
    appendToFileIfNotFound "${grubConfigFile}" "$(stringToSearchPattern "${grubConfigAttribute}")" "${grubConfigAttribute}" 'true' 'false' 'true'

    update-grub

    # Start

    startService 'docker'

    # Display Info

    header 'DISPLAYING DOCKER INFO AND STATUS'
    info "\n$(docker info)"

    # Display Version

    displayVersion "$(docker version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING DOCKER'

    install
    installCleanUp
}

main "${@}"