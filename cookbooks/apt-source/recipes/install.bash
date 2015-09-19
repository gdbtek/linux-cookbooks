#!/bin/bash -e

function install()
{
    # Install

    local -r sourceListFile="${appPath}/../files/$(getMachineRelease).list.conf"

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
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING APT-SOURCE'

    install
    installCleanUp
}

main "${@}"