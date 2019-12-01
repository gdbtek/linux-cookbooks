#!/bin/bash -e

function install()
{
    umask '0022'

    createFileFromTemplate \
        "$(dirname "${BASH_SOURCE[0]}")/../templates/delete-old-logs.bash" \
        '/etc/cron.hourly/delete-old-logs' \
        '__LOG_FOLDER_PATHS__' "$(arrayToParameters "${CLEAN_UP_OLD_LOG_FOLDER_PATHS[@]}")"

    chmod 755 '/etc/cron.hourly/delete-old-logs'
    cat '/etc/cron.hourly/delete-old-logs'
    echo

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING DELETE-OLD-LOGS'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"