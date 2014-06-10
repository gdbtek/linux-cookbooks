#!/bin/bash

function installDependencies()
{
    runAptGetUpdate
}

function install()
{
    installPackage 'vim'
    cp -f "${appPath}/../files/conf/vimrc.local" '/etc/vim/vimrc.local'
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1

    checkRequireDistributor

    header 'INSTALLING VIM'

    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"