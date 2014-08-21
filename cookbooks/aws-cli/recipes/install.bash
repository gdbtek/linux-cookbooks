#!/bin/bash -e

function install()
{
    installPIPPackage 'awscli'
    info "\n$(aws --version 2>&1)"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING AWS-CLI'

    install
    installCleanUp
}

main "${@}"