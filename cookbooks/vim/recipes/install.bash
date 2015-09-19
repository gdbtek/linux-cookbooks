#!/bin/bash -e

function install()
{
    installAptGetPackages 'vim'
    cp -f "${appPath}/../files/vimrc.local.conf" '/etc/vim/vimrc.local'
}

function main()
{
    appPath="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # shellcheck source=/dev/null
    source "${appPath}/../../../libraries/util.bash"

    checkRequireSystem
    checkRequireRootUser

    header 'INSTALLING VIM'

    install
    installCleanUp
}

main "${@}"