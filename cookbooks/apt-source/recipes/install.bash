#!/bin/bash -e

function install()
{
    # Install

    local sourceListFile="${appPath}/../files/default/$(getMachineRelease).list.conf"

    if [[ -f "${sourceListFile}" ]]
    then
        cp -f "${sourceListFile}" '/etc/apt/sources.list'
        cat '/etc/apt/sources.list'
        echo
    else
        warn "WARN: this cookbook has not supported '$(getMachineDescription)' yet!"
    fi
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING APT-SOURCE'

    install
    installCleanUp
}

main "${@}"