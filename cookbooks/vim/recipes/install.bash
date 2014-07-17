#!/bin/bash

function installDependencies()
{
    runAptGetUpdate
}

function install()
{
    installAptGetPackages 'vim'
    cp -f "${appPath}/../files/conf/vimrc.local" '/etc/vim/vimrc.local'
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING VIM'

    installDependencies
    install
    installCleanUp
}

main "${@}"