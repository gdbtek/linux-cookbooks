#!/bin/bash -e

function install()
{
    umask '0022'

    # Install Package

    installPackages 'logrotate'

    # Configure Logrotate

    if [[ "$(isUbuntuDistributor)" = 'true' ]]
    then
        cp -f "$(dirname "${BASH_SOURCE[0]}")/../files/logrotate.conf.apt" '/etc/logrotate.conf'
    else
        cp -f "$(dirname "${BASH_SOURCE[0]}")/../files/logrotate.conf.rpm" '/etc/logrotate.conf'
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
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    header 'INSTALLING LOGROTATE'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"