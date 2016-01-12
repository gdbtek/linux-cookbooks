#!/bin/bash -e

function installDependencies()
{
    runAptGetUpgrade
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING ESSENTIAL PACKAGES'

    installDependencies
    installAptGetPackages "${ESSENTIAL_PACKAGES[@]}"
    installCleanUp
}

main "${@}"