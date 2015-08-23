#!/bin/bash -e

function installDependencies()
{
    cp -f "${appPath}/../files/default/aufs.conf.upstart" '/etc/init/aufs.conf'
    start 'aufs'
}

function install()
{
    # Download and Install

    checkExistURL "${DOCKER_DOWNLOAD_URL}"
    debug "\nDownloading '${DOCKER_DOWNLOAD_URL}'\n"
    curl -L "${DOCKER_DOWNLOAD_URL}" --retry 12 --retry-delay 5 | bash -e

    # Config Grub

    header 'UPDATING GRUB CONFIG'

    local -r grubConfigFile='/etc/default/grub'

    local -r grubConfigAttribute='GRUB_CMDLINE_LINUX="cgroup_enable=memory swapaccount=1"'
    local -r grubConfigData=('GRUB_CMDLINE_LINUX=""' "${grubConfigAttribute}")

    createFileFromTemplate "${grubConfigFile}" "${grubConfigFile}" "${grubConfigData[@]}"
    appendToFileIfNotFound "${grubConfigFile}" "$(stringToSearchPattern "${grubConfigAttribute}")" "${grubConfigAttribute}" 'true' 'false' 'true'

    update-grub

    # Display Version

    header 'DISPLAYING DOCKER VERSION'
    info "$(docker --version)"
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING DOCKER'

    installDependencies
    install
    installCleanUp
}

main "${@}"