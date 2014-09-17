#!/bin/bash -e

function install()
{
    upgradePIPPackage 'awscli'
    info "\n$(aws --version 2>&1)"
}

function main()
{
    local appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'UPGRADING AWS-CLI'

    install
    installCleanUp
}

main "${@}"