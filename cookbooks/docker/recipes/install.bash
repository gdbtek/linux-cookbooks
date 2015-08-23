#!/bin/bash -e

function installDependencies()
{
    installAptGetPackage "linux-image-extra-$(uname -r)"
    modprobe aufs
}

function install()
{
    checkExistURL "${DOCKER_DOWNLOAD_URL}"
    debug "Downloading '${DOCKER_DOWNLOAD_URL}'\n"
    curl -L "${DOCKER_DOWNLOAD_URL}" --retry 12 --retry-delay 5 | bash -e
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