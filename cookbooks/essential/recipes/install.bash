#!/bin/bash -e

function installDependencies()
{
    runUpgrade
}

function install()
{
    umask '0022'

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        installPackages "${APT_ESSENTIAL_PACKAGES[@]}"
    else
        installPackages "${RPM_ESSENTIAL_PACKAGES[@]}"
    fi

    umask '0077'
}

function main()
{
    local -r appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"
    source "${appFolderPath}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING ESSENTIAL PACKAGES'

    installDependencies
    install
    installCleanUp
}

main "${@}"