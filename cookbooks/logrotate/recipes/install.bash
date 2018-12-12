#!/bin/bash -e

function install()
{
    umask '0022'

    # Install Package

    installPackages 'logrotate'

    # Configure Logrotate

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        cp -f "${APP_FOLDER_PATH}/../files/logrotate.conf.apt" '/etc/logrotate.conf'
    else
        cp -f "${APP_FOLDER_PATH}/../files/logrotate.conf.rpm" '/etc/logrotate.conf'
    fi

    info '/etc/logrotate.conf'
    indentString '  ' "$(cat '/etc/logrotate.conf')"

    # Configure Cron

    cp -f -p '/etc/cron.daily/logrotate' '/etc/cron.hourly/logrotate'

    info '\n/etc/cron.hourly/logrotate'
    indentString '  ' "$(cat '/etc/cron.hourly/logrotate')"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING LOGROTATE'

    install
    installCleanUp
}

main "${@}"