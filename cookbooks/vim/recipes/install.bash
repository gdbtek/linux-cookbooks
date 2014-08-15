#!/bin/bash -e

function install()
{
    installAptGetPackages 'vim'
    cp --force "${appPath}/../files/default/vimrc.local.conf" '/etc/vim/vimrc.local'
}

function main()
{
    appPath="$(cd "$(dirname "${0}")" && pwd)"

    source "${appPath}/../../../lib/util.bash" || exit 1

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING VIM'

    install
    installCleanUp
}

main "${@}"