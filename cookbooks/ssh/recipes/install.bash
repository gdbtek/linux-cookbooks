#!/bin/bash -e

function install()
{
    local package=''

    for config in "${SSH_CONFIGS[@]}"
    do
        header "ADDING SSH CONFIG ${config}"
    done
}

function main()
{
    local -r appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"
    source "${appPath}/../attributes/default.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING SSH'

    install
    installCleanUp
}

main "${@}"