#!/bin/bash -e

function install()
{
    installAptGetPackages 'vim'
    cp -f "${appPath}/../files/default/vimrc.local.conf" '/etc/vim/vimrc.local'
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appPath}/../../../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING VIM'

    install
    installCleanUp
}

main "${@}"