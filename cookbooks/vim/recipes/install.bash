#!/bin/bash -e

function install()
{
    umask '0022'

    installPackages 'vim'

    mkdir -p '/etc/vim'
    chmod 755 '/etc/vim'
    cp -f "${APP_FOLDER_PATH}/../files/vimrc.local.conf" '/etc/vim/vimrc.local'
    chmod 644 '/etc/vim/vimrc.local'

    if [[ "$(isAmazonLinuxDistributor)" = 'true' || "$(isCentOSDistributor)" = 'true' || "$(isRedHatDistributor)" = 'true' ]]
    then
        local -r aliasCommand='alias vi=vim'
        local -r sourceCommand='source /etc/vim/vimrc.local'

        appendToFileIfNotFound '/etc/profile' "${aliasCommand}" "${aliasCommand}" 'false' 'false' 'true'
        appendToFileIfNotFound '/etc/vimrc' "${sourceCommand}" "${sourceCommand}" 'false' 'false' 'true'
    fi

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING VIM'

    install
    installCleanUp
}

main "${@}"