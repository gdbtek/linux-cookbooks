#!/bin/bash

function installDependencies()
{
    runAptGetUpgrade
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING ESSENTIAL PACKAGES'

    installDependencies
    installAptGetPackages "${essentialPackages[@]}"
    installCleanUp
}

main "${@}"