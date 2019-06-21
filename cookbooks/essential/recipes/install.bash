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
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING ESSENTIAL PACKAGES'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"