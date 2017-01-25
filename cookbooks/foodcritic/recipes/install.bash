#!/bin/bash -e

function installDependencies()
{
    if [[ "$(existCommand 'ruby')" = 'false' || ! -d "${FOODCRITIC_RUBY_INSTALL_FOLDER_PATH}" ]]
    then
        "${APP_FOLDER_PATH}/../../ruby/recipes/install.bash" "${FOODCRITIC_RUBY_INSTALL_FOLDER_PATH}"
    fi
}

function install()
{
    umask '0022'

    # Install

    gem install foodcritic

    if [[ -f "${FOODCRITIC_RUBY_INSTALL_FOLDER_PATH}/bin/foodcritic" ]]
    then
        ln -f -s "${FOODCRITIC_RUBY_INSTALL_FOLDER_PATH}/bin/foodcritic" '/usr/local/bin/foodcritic'
    fi

    # Display Version

    displayVersion "$(foodcritic --version)"

    umask '0077'
}

function main()
{
    APP_FOLDER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    source "${APP_FOLDER_PATH}/../../../libraries/util.bash"
    source "${APP_FOLDER_PATH}/../attributes/default.bash"

    checkRequireLinuxSystem
    checkRequireRootUser

    header 'INSTALLING FOODCRITIC'

    # Install

    installDependencies
    install
    installCleanUp
}

main "${@}"