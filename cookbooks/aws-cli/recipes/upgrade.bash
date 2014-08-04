#!/bin/bash -e

function install()
{
    upgradePIPPackage 'awscli'
    info "\n$(aws --version 2>&1)"
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    header 'UPGRADING AWS-CLI'

    install
    installCleanUp
}

main "${@}"