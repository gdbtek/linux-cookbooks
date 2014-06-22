#!/bin/bash

function install()
{
    # Install

    local sourceListFile="${appPath}/../files/conf/$(getMachineRelease).list"

    if [[ -f "${sourceListFile}" ]]
    then
        cp -f "${sourceListFile}" '/etc/apt/sources.list' &&
        cat '/etc/apt/sources.list' &&
        echo
    else
        warn "WARN: this cookbook has not supported '$(getMachineDescription)' yet!"
    fi
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING APT-SOURCE'

    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"