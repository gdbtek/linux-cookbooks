#!/bin/bash

function installDependencies()
{
    runAptGetUpdate

    installPackage 'python-pip'
}

function install()
{
    pip install awscli &&
    aws --version
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