#!/bin/bash -e

function install()
{
    umask '0022'

    # Install

    local -r sourceListFile="${APP_FOLDER_PATH}/../files/$(getMachineRelease).list.conf"

    if [[ -f "${sourceListFile}" ]]
    then
        cp -f "${sourceListFile}" '/etc/apt/sources.list'
        cat '/etc/apt/sources.list'
        echo
    else
        warn "WARN : '$(getMachineDescription)' not supported"
    fi

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING APT-SOURCE'

    install
    installCleanUp
}

main "${@}"