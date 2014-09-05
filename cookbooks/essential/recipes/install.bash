#!/bin/bash -e

function installDependencies()
{
    runAptGetUpgrade
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING ESSENTIAL PACKAGES'

    installDependencies
    installAptGetPackages "${essentialPackages[@]}"
    installCleanUp
}

main "${@}"