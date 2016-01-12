#!/bin/bash -e

function install()
{
    # Install

    local -r sourceListFile="${appFolderPath}/../files/$(getMachineRelease).list.conf"

    if [[ -f "${sourceListFile}" ]]
    then
        cp -f "${sourceListFile}" '/etc/apt/sources.list'
        cat '/etc/apt/sources.list'
        echo
    else
        warn "WARN : '$(getMachineDescription)' not supported"
    fi
}

function main()
{
    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING APT-SOURCE'

    install
    installCleanUp
}

main "${@}"