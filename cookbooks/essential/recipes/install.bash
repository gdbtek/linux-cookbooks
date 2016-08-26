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

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        installPackages "${APT_ESSENTIAL_PACKAGES[@]}"
    elif [[ "$(isCentOSDistributor)" = 'true' || "$(isRedHatDistributor)" = 'true' ]]
    then
        installPackages "${RPM_ESSENTIAL_PACKAGES[@]}"
    else
        fatal '\nFATAL : only support CentOS, RedHat or Ubuntu OS'
    fi

    installCleanUp
}

main "${@}"