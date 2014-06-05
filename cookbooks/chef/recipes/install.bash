#!/bin/bash

function install()
{
    curl -L "${downloadURL}" | bash
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING CHEF'

    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"