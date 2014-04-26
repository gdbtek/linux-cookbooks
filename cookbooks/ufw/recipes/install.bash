#!/bin/bash

function installDependencies()
{
    apt-get update
}

function install()
{
    apt-get install -y ufw

    for policy in "${policies[@]}"
    do
        ufw ${policy}
    done

    ufw enable
    ufw status
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1
    source "${appPath}/../attributes/default.bash" || exit 1

    header 'INSTALLING FIREWALL'

    checkRequireRootUser

    installDependencies
    install
}

main "${@}"
