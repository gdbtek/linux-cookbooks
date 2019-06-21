#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'ruby')" = 'false' || ! -d "${FOODCRITIC_RUBY_INSTALL_FOLDER_PATH}" ]]
    then
        "$(dirname "${BASH_SOURCE[0]}")/../../ruby/recipes/install.bash" "${FOODCRITIC_RUBY_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    umask '0022'

    gem install foodcritic

    if [[ -f "${FOODCRITIC_RUBY_INSTALL_FOLDER_PATH}/bin/foodcritic" ]]
    then
        ln -f -s "${FOODCRITIC_RUBY_INSTALL_FOLDER_PATH}/bin/foodcritic" '/usr/bin/foodcritic'
    fi

    displayVersion "$(foodcritic --version)"

    umask '0077'
}

function main()
{
    source "$(dirname "${BASH_SOURCE[0]}")/../../../libraries/util.bash"
    source "$(dirname "${BASH_SOURCE[0]}")/../attributes/default.bash"

    header 'INSTALLING FOODCRITIC'

    checkRequireLinuxSystem
    checkRequireRootUser

    installDependencies
    install
    installCleanUp
}

main "${@}"