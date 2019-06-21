#!/bin/bash -e

function install()
{
    umask '0022'

    cp -f "$(dirname "${BASH_SOURCE[0]}")/../files/delete-old-logs" '/etc/cron.hourly'
    chmod 755 '/etc/cron.hourly/delete-old-logs'
    cat '/etc/cron.hourly/delete-old-logs'
    echo

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    header 'INSTALLING DELETE-OLD-LOGS'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"