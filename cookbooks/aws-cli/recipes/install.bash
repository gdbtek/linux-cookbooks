#!/bin/bash

function installDependencies()
{
    apt-get update

    apt-get install -y python-pip
}

function install()
{
    pip install awscli
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1

    header 'INSTALLING AWS-CLI'

    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"
