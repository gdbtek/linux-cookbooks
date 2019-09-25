#!/bin/bash -e

function install()
{
    umask '0022'

    "$(dirname "${BASH_SOURCE[0]}")/install-server.bash"
    "$(dirname "${BASH_SOURCE[0]}")/install-agent.bash"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"