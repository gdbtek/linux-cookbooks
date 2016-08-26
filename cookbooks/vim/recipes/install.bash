#!/bin/bash -e

function install()
{
    installPackage 'vim' 'vim'
    cp -f "${APP_FOLDER_PATH}/../files/vimrc.local.conf" '/etc/vim/vimrc.local'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING VIM'

    install
    installCleanUp
}

main "${@}"