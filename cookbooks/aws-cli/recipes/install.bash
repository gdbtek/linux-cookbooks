#!/bin/bash

function installDependencies()
{
    runAptGetUpdate

    apt-get install -y python-pip
}

function install()
{
    pip install awscli
}

function main()
{
    local appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING AWS-CLI'

    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"
