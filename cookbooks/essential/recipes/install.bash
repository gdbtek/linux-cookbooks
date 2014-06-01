#!/bin/bash

function installDependencies()
{
    apt-get update
}

function install()
{
    apt-get install -y "${packages[@]}"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING ESSENTIAL PACKAGES'

    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"
