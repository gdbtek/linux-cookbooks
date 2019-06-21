#!/bin/bash -e

function install()
{
    umask '0022'

    installPackages 'vim'

    mkdir -p '/etc/vim'
    chmod 755 '/etc/vim'
    cp -f "$(dirname "${BASH_SOURCE[0]}")/../files/vimrc.local.conf" '/etc/vim/vimrc.local'
    chmod 644 '/etc/vim/vimrc.local'

    if [[ "$(isAmazonLinuxDistributor)" = 'true' || "$(isCentOSDistributor)" = 'true' || "$(isRedHatDistributor)" = 'true' ]]
    then
        appendToFileIfNotFound '/etc/profile' 'alias vi=vim' 'alias vi=vim' 'false' 'false' 'true'
        appendToFileIfNotFound '/etc/vimrc' 'source /etc/vim/vimrc.local' 'source /etc/vim/vimrc.local' 'false' 'false' 'true'
    fi

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"

    header 'INSTALLING VIM'

    checkRequireLinuxSystem
    checkRequireRootUser

    install
    installCleanUp
}

main "${@}"