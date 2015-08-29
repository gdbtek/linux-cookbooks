#!/bin/bash -e

function installDependencies()
{
    local -r requireModule='aufs'

    if [[ "$(existModule "${requireModule}")" = 'false' ]]
    then
        installAptGetPackage "linux-image-extra-$(uname -r)"
        modprobe "${requireModule}"
    fi
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

    # Config AUFS Upstart

    header 'UPDATING AUFS UPSTART'
    cp -f "${appPath}/../files/default/aufs.conf.upstart" '/etc/init/aufs.conf'

    # Display Version

    header 'DISPLAYING DOCKER INFO AND STATUS'
    info "$(docker version)"
    info "\n$(docker info)"
    info "\n$(status 'docker')"

    # Display Open Ports

    displayOpenPorts '5'
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