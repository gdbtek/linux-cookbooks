#!/bin/bash -e

function install()
{
    umask '0022'

    cp -f "${APP_FOLDER_PATH}/../files/delete-old-logs" '/etc/cron.hourly'
    chmod 755 '/etc/cron.hourly/delete-old-logs'
    cat '/etc/cron.hourly/delete-old-logs'
    echo

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING DELETE-OLD-LOGS'

    install
    installCleanUp
}

main "${@}"