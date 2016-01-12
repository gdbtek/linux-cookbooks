#!/bin/bash -e

function install()
{
    installAptGetPackages 'vim'
    cp -f "${appFolderPath}/../files/vimrc.local.conf" '/etc/vim/vimrc.local'
}

function main()
{
    appFolderPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${appFolderPath}/../../../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING VIM'

    install
    installCleanUp
}

main "${@}"