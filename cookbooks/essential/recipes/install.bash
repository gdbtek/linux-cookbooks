#!/bin/bash

function installDependencies()
{
    runAptGetUpdate
    runAptGetUpgrade
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireSystem

    header 'INSTALLING ESSENTIAL PACKAGES'

    checkRequireRootUser

    installDependencies
    installAptGetPackages "${essentialPackages[@]}"
    installCleanUp
}

main "${@}"