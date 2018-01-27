#!/bin/bash -e

function installDependencies()
{
    local -r requireModule='aufs'

    if [[ "$(existModule "${requireModule}")" = 'false' ]]
    then
        installPackage "linux-image-extra-$(uname -r)"
        modprobe "${requireModule}"
    fi
}

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

    # Config AUFS Init

    createInitFileFromTemplate 'aufs' "${APP_FOLDER_PATH}/../files"

    # Start

    startService 'aufs'
    startService 'docker'

    # Display Info and Status

    header 'DISPLAYING DOCKER INFO AND STATUS'
    info "\n$(docker info)"
    info "\n$(status 'docker')"

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

    installDependencies
    install
    installCleanUp
}

main "${@}"